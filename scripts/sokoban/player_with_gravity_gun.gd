extends CharacterBody2D


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var jump_audio: AudioStreamPlayer2D = $jump_audio
@export var mass: float = 1.0
@export var second_jump_enabled = true
@export var ammo_count = 1 # 子弹数量
@export var coyote_time: float = 0.2 # 离开平台边缘还能起跳的时间，为了更宽松的平台边缘的跳跃

# run variables
@export var acceleration_frames: int = 3 # 达到最高速需要的帧数
@export var deceleration_frames: int = 3 # 减速到0需要的帧数

# jump variables
@export var jump_acceleration_frames: int = 4 # 达到最高跳跃速度需要的帧数
@export var jump_deceleration_frames: int = 5 # 减速到0需要的帧数

# shadow/ after image / 残影
@export var after_image_scene: PackedScene
var after_image_timer: float = 0.0
var after_image_interval: float = 0.05
var can_destroy = false


# hook variables
var is_hooking = false
var hook_target = null
@export var hook_speed = 500.0 # 钩爪速度
var hook_strength = 20.0 # 钩爪强度
var hook_duration = 5  # 钩爪最大持续时间(秒)
var hook_timer = 0.0    # 计时器
var hookable_areas: Array = []


var player_state = 'idle' # 玩家状态(can move or not)
var has_double_jumped = false
var second_jump_gravity_timer: float = 0.2
var second_jump_gravity_value: float = 1
var has_released_jump: bool = false
var facing_direction = 1
var can_move = true
var jump_buffer_timer: float = 0.0 # 记录跳跃键按下的时间
var jump_hold_time: float = 0.0 # 记录跳跃键按住的时间
var is_jumping: bool = false # 标记是否正在跳跃
var default_pos = Vector2(0, 0)
var respawn_pos = Vector2(0, 0)
var coyote_timer: float = 0.0
var was_on_ground: bool = false
var current_speed: float = 0.0
var jump_acceleration_counter: int = 0

var active_gravity_gun_fields: Array = []

var gravity_scene = preload("res://scenes/sokoban/gravity_1.tscn")

# 在类变量中添加
var ground_contact_frames: int = 0      # 接触地面的帧数
const GROUND_CONTACT_THRESHOLD: int = 2  # 需要2帧才确认离开地面

# logging
var jump_start_position: Vector2 = Vector2.ZERO

@export var fall_multiplier_duration: float = 0.2  # 加倍重力的持续时间(秒)
var fall_multiplier_timer: float = 0.0  # 计时器

# 在类变量中添加
var last_hook_position: Vector2 = Vector2.ZERO
var stuck_check_timer: float = 0.0
var stuck_check_interval: float = 0.1  # 检查间隔时间
var stuck_distance_threshold: float = 5.0  # 判定为卡住的距离阈值

func _ready():
	await ready
	GameManager.load_game_state()
	print('game state', GameManager.game_state)
	# 只在初始加载时设置位置,而不是reload
	var current_scene_path = get_tree().current_scene.scene_file_path
	if GameManager.game_state['last_scene_path'] == current_scene_path:
		if GameManager.game_state['current_respawn_point_x'] != null:
			respawn_pos = Vector2(GameManager.game_state['current_respawn_point_x'], GameManager.game_state['current_respawn_point_y'])
			global_position = respawn_pos

	$HookableDetector.area_entered.connect(_on_hookable_area_entered)
	$HookableDetector.area_exited.connect(_on_hookable_area_exited)

	add_to_group("player")
	set_can_move(true)


func respawn():
	# 直接重新加载场景,不做其他处理
	get_tree().reload_current_scene()

# 开始跳跃的函数
func start_jump() -> void:
	# logging
	jump_start_position = global_position

	has_released_jump = false
	has_double_jumped = false
	var gravity_dir = get_gravity().normalized()
	
	# 添加水平方向的速度提升
	var perpendicular_dir = Vector2(-gravity_dir.y, gravity_dir.x)  # 垂直于重力方向的向量
	var horizontal_input = Input.get_axis("left", "right")
	if horizontal_input != 0:
		velocity += perpendicular_dir * (Consts.SPEED  * horizontal_input)  # 可以调整这个系数
	
	# 将跳跃速度分成多帧加速
	var jump_speed_per_frame = abs(Consts.MAX_JUMP_VELOCITY) / jump_acceleration_frames
	velocity -= gravity_dir * jump_speed_per_frame
	
	jump_hold_time = 0.0
	jump_acceleration_counter = 0
	is_jumping = true
	if jump_audio and jump_audio.stream:
		jump_audio.play()

func set_can_move(value: bool,state='idle') -> void:
	can_move = value
	player_state = state 
	

func _physics_process(delta: float) -> void:
	if not can_move:
		if player_state == 'death':
			animated_sprite_2d.play('death')
			# 死亡状态下仍然受到重力和惯性影响
			var gravity = get_gravity()
			velocity += gravity * delta
			velocity.x = velocity.x * 0.95
			move_and_slide()
		elif player_state == 'jump':
			animated_sprite_2d.play('jump')
			var gravity = get_gravity()
			velocity += gravity * delta
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			animated_sprite_2d.play('idle')
		return
	var player_height = 16.0  # 角色高度为16像素
	if is_jumping:
		# 计算当前位置与起跳位置的距离(考虑重力方向)
		var gravity_dir = get_gravity().normalized()
		var height_diff = (jump_start_position - global_position).project(-gravity_dir).length()
		var height_in_player_units = height_diff / player_height
		#print('height_diff', height_diff)
		#print("当前跳跃高度: %.2f 个角色高度" % height_in_player_units)

	# if jump_buffer_timer > 0:
	# 	print('jump buffer timer', jump_buffer_timer)
	# if Input.is_action_just_pressed('jump'):
		# print('jump pressed')
	# 在函数开始时就检查 can_move


		
	if Input.is_action_just_pressed("reload"):
		respawn()

	# Add the gravity.
	
	# print('is on terrain', is_on_terrain())
	if not is_on_terrain():
		# print('not on terrain')
		#print(collision_shape_2d.collision_mask)
		if was_on_ground:  # Only start coyote time when first leaving ground
			coyote_timer = coyote_time
			was_on_ground = false
		else:
			coyote_timer -= delta  # Only decrease timer if we're already in air
		
		var gravity = get_gravity()
		var gravity_dir = gravity.normalized()
		
		# 先应用重力
		# velocity += gravity * delta
		
		# 然后限制重力方向上的速度分量
		var velocity_along_gravity = velocity.project(gravity_dir)
		if velocity_along_gravity.length() > Consts.MAX_FALLING_SPEED:
			# 将重力方向的速度限制在400
			velocity_along_gravity = velocity_along_gravity.normalized() * Consts.MAX_FALLING_SPEED
			# 计算垂直于重力方向的速度分量
			var velocity_perpendicular = velocity - velocity.project(gravity_dir)
			# 合并两个速度分量
			velocity = velocity_along_gravity + velocity_perpendicular
		
		jump_buffer_timer -= delta # 在空中时，减少缓冲计时器

		# print('has released jump1: ', has_released_jump)
		if Input.is_action_just_released('jump'):
			has_released_jump = true

		# 如果玩家正在跳跃并且继续按住跳跃键，增加跳跃高度

		if is_jumping and Input.is_action_pressed('jump'):
			jump_hold_time += delta
			var velocity_projection = velocity.project(gravity_dir).length()
			
			if jump_acceleration_counter < jump_acceleration_frames:
				# 初始加速阶段
				var target_velocity = -gravity_dir * abs(Consts.JUMP_VELOCITY)
				var lerp_weight = 1.0 / jump_acceleration_frames
				velocity = lerp(velocity, target_velocity, lerp_weight)
				jump_acceleration_counter += 1
			elif jump_hold_time < Consts.MAX_JUMP_HOLD_TIME:
				# 持续按住跳跃键时保持向上的力
				velocity -= gravity_dir * (Consts.MAX_JUMP_VELOCITY * -0.6) * delta
			else:
				is_jumping = false
				# 只在开始下落后的短时间内应用加倍重力
				if velocity.dot(gravity_dir) > 0:  # 检查是否在下落
					if fall_multiplier_timer < fall_multiplier_duration:
						velocity += gravity * delta * 1.8  # 加倍重力
						fall_multiplier_timer += delta
					else:
						velocity += gravity * delta  # 正常重力
				else:
					fall_multiplier_timer = 0.0  # 重置计时器
					velocity += gravity * delta
		else:
			is_jumping = false
			# 只在开始下落后的短时间内应用加倍重力
			if velocity.dot(gravity_dir) > 0:  # 检查是否在下落
				if fall_multiplier_timer < fall_multiplier_duration:
					velocity += gravity * delta * 1.5  # 加倍重力
					fall_multiplier_timer += delta
				else:
					velocity += gravity * delta  # 正常重力
			else:
				fall_multiplier_timer = 0.0  # 重置计时器
				velocity += gravity * delta
		# 二段跳
		
		# print('has released jump2: ', has_released_jump)
		if not has_double_jumped and has_released_jump and Input.is_action_just_pressed('jump') and can_second_jump() and coyote_timer <= 0:
		# if second_jump_enabled and has_released_jump: # 筋斗云
			has_double_jumped = true
			gravity_dir = get_gravity().normalized()
			if velocity_along_gravity.dot(gravity_dir) > 0:	
				velocity_along_gravity = velocity.project(gravity_dir)
				var velocity_perpendicular = velocity - velocity_along_gravity
				velocity = velocity_perpendicular + (velocity_along_gravity * -0.1)
			set_gravity(Vector2(0, -second_jump_gravity_value))
			# second_jump_enabled = false

	else:
		# Reset flags when touching ground
		was_on_ground = true
		coyote_timer = 0  # Reset coyote timer when on ground
		has_double_jumped = false
		if jump_buffer_timer > 0 and has_released_jump:
			print('try pre imput jump')
			start_jump()
			print('reset jump buffer timer')
			jump_buffer_timer = 0

	if is_jumping:
		was_on_ground = false
		coyote_timer = 0
	# Handle jump input with buffering
	if Input.is_action_just_pressed("jump"):
		# print('is on terrain', is_on_terrain()
		if (is_on_terrain() or coyote_timer > 0) and can_move:
			if coyote_timer > 0:
				print('coyote jump')
			start_jump() # 正常跳跃
		else:
			jump_buffer_timer = Consts.JUMP_BUFFER_TIME # 记录跳跃键按下的时间以便缓冲
	#
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)
	
	update_face_direction(direction.x)

	# hook

	if Input.is_action_just_pressed("hook"):
		var nearest_field = find_nearest_hookable_area()
		# print('nearest field', nearest_field)
		if nearest_field:
			hook(nearest_field)
			hook_target = nearest_field
	if is_hooking and is_instance_valid(hook_target):
		hook_timer += delta
		after_image_timer += delta

		if after_image_timer >= after_image_interval:
			spawn_after_image()
			after_image_timer = 0.0

		if hook_timer >= hook_duration:
			end_hook()
			return
			
		var hook_target_position = hook_target.get_hook_position()
		var hook_direction = (hook_target_position - global_position).normalized()
		var hook_distance = global_position.distance_to(hook_target_position)
		
		# 如果距离很近，结束钩爪状态
		if hook_distance < 10:
			end_hook()
			return
			
		# 检查是否卡住
		stuck_check_timer += delta
		if stuck_check_timer >= stuck_check_interval:
			var moved_distance = global_position.distance_to(last_hook_position)
			if moved_distance < stuck_distance_threshold:
				# 如果在检查间隔内移动距离小于阈值，认为卡住了
				end_hook()
				return
			# 更新位置和计时器
			last_hook_position = global_position
			stuck_check_timer = 0.0
		
				
		# 计算钩爪力
		var target_velocity = hook_direction * hook_speed
		# 使用插值平滑过渡到目标速度
		velocity = velocity.lerp(target_velocity, 0.8)
		velocity += get_gravity() * delta * 1
		
		# 仍然应用重力，但减小影响
		# var gravity = get_gravity() * delta * 0.3
		# velocity += gravity	
	# TODO: fix this on different gravity direction
	# Flip sprite based on movement direction 
	
	# Flip sprite based on gravity dirction
	filp_player_sprite(direction)

	# paly animations
	if is_on_terrain():
		if direction.x == 0 and direction.y == 0:
			animated_sprite_2d.play('idle')
		else:
			animated_sprite_2d.play('move')
	else:
		animated_sprite_2d.play(('jump'))
		

	# Handle movement
	# if direction:
	# 	# 根据重力方向调整移动
	# 	if abs(get_gravity().y) > abs(get_gravity().x):
	# 		# 垂直重力情况（向上或向下）
	# 		velocity.x = direction.x * Consts.SPEED
	# 	else:
	# 		# 水平重力情况（向左或向右）
	# 		velocity.y = direction.y * Consts.SPEED # 使用 direction.y 来控制上下移动
	if direction and not is_hooking:
		# print('into handle movement')
		# 根据重力方向调整移动
		var speed_step = Consts.SPEED / acceleration_frames  # 每帧增加的速度
		if abs(get_gravity().y) > abs(get_gravity().x):
			# 水平移动
			var target_speed = direction.x * Consts.SPEED
			if sign(target_speed) != sign(current_speed):
				current_speed = 0  # 改变方向时重置速度
			current_speed = clamp(
				current_speed + (speed_step * sign(target_speed)),
				-Consts.SPEED,
				Consts.SPEED
			)
			velocity.x = current_speed
		else:
			# 垂直移动
			var target_speed = direction.y * Consts.SPEED
			if sign(target_speed) != sign(current_speed):
				current_speed = 0  # 改变方向时重置速度
			current_speed = clamp(
				current_speed + (speed_step * sign(target_speed)),
				-Consts.SPEED,
				Consts.SPEED
			)
			velocity.y = current_speed
		
		check_box_on_head()
		# 检测头顶上方的箱子
		
		
	elif not direction and not is_hooking:

		var speed_step = Consts.SPEED / deceleration_frames  # 每帧减少的速度
		if abs(current_speed) <= speed_step:
			current_speed = 0
		else:
			current_speed = move_toward(current_speed, 0, speed_step)
		
		if abs(get_gravity().y) > abs(get_gravity().x):
			velocity.x = current_speed
		else:
			velocity.y = current_speed
		
	# var collision_collider = move_and_collide(velocity * delta)
	
	# # 处理碰撞
	# if collision_collider:
	# 	var collider = collision_collider.get_collider()
		
	# 	# 如果碰撞体是 CharacterBody2D
	# 	if collider is CharacterBody2D:
	# 		var normal = collision_collider.get_normal()
	# 		var relative_velocity = velocity - collider.velocity
	# 		var impulse = relative_velocity.dot(normal) * 0.5  # 0.5 是弹性系数
			
	# 		# 直接修改两个物体的速度
	# 		velocity = velocity - normal * impulse
	# 		collider.velocity = collider.velocity + normal * impulse
			
	# 		# 让引擎处理实际的移动
	# 		collider.move_and_collide(collider.velocity * delta)

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is CharacterBody2D and collider.is_in_group('pushable'):
			# print('push box')
			# 获取碰撞法线
			var normal = collision.get_normal()
			var gravity_dir = get_gravity().normalized()
			
			# 检查是否从侧面推动（碰撞法线与重力方向垂直）
			if abs(normal.dot(gravity_dir)) < 0.1:
				# 计算与重力方向垂直的方向向量
				var perpendicular_dir = Vector2(-gravity_dir.y, gravity_dir.x)
				# 计算输入方向在垂直方向上的投影
				var projected_direction = direction.project(perpendicular_dir)
				
				# 只有当投影后的方向有效时才推动箱子
				if projected_direction.length() > 0:
					collider.push(projected_direction.normalized())
			# elif abs(normal.dot(gravity_dir)) > 0.9:
			# 	if collider.is_in_group("bouncy"):
			# 		# 如果是弹性箱子，给玩家一个向上的速度
			# 		velocity = -gravity_dir * Consts.MAX_JUMP_VELOCITY * 1.2
			# 	else:
			# 		var relative_velocity = velocity - collider.velocity
			# 		var impulse = relative_velocity.dot(normal) * mass / (mass + collider.mass)
					
			# 		# 更新速度
			# 		velocity -= normal * impulse
			# 		collider.velocity += normal * impulse
			# 		collider.stomp(normal * impulse * mass/ collider.mass, delta)


	# 在处理移动之前检查can_move
	if not can_move:
		# 如果不能移动，将速度设为0并继续处理其他逻辑
		velocity.x = 0
		velocity.y = 0
		move_and_slide()
		return
	
	move_and_slide()
	# push boxes
	
	
	# print player status
	# print(get_gravity())
	# print('position', position)
	# print('velocity', velocity)
	# print('is on terrain', is_on_terrain())
	
	# 添加边角碰撞检测和修正
	handle_corner_correction()
	
func update_face_direction(direction):
	if direction != 0:
		facing_direction = direction


func is_on_terrain() -> bool:
	set_up_direction(-get_gravity().normalized())
	var is_touching_ground = is_on_floor()
	
	# 更新接触帧数
	if is_touching_ground:
		ground_contact_frames = GROUND_CONTACT_THRESHOLD  # 立即接触时设为最大值
	elif ground_contact_frames > 0:
		ground_contact_frames -= 1  # 离开地面时逐帧减少
	# logging	
	# if get_gravity().x != 0:
	# 	print('is on floor', is_on_floor())
	# 	print('ground contact frames', ground_contact_frames)
	
	# 只要计数器大于0就认为在地面上
	return ground_contact_frames > 0
	# return true

func filp_player_sprite(direction):
	# flip palyer sprite based on gravity direction
	var gravity = get_gravity().normalized()
	var angle = gravity.angle() - PI / 2 # 加90度使角色垂直于重力方向
	animated_sprite_2d.rotation = angle
	collision_shape_2d.rotation = angle

	if abs(gravity.y) > abs(gravity.x):
		# 垂直重力情况
		if gravity.y > 0: # 重力向下
			if direction.x > 0:
				animated_sprite_2d.flip_h = false
			elif direction.x < 0:
				animated_sprite_2d.flip_h = true
		else: # 重力向上
			if direction.x > 0:
				animated_sprite_2d.flip_h = true
			elif direction.x < 0:
				animated_sprite_2d.flip_h = false
	else:
		# 水平重力情况保持不变
		if gravity.x > 0: # 重力向右
			if direction.y > 0:
				animated_sprite_2d.flip_h = true
			elif direction.y < 0:
				animated_sprite_2d.flip_h = false
		else: # 重力向左
			if direction.y > 0:
				animated_sprite_2d.flip_h = false
			elif direction.y < 0:
				animated_sprite_2d.flip_h = true

func free_player_from_box(box: CharacterBody2D) -> void:
	var gravity_dir = get_gravity().normalized()
	
	# 给箱子一个向上的力
	var push_force = -gravity_dir * Consts.SPEED * 0.5
	box.velocity = push_force
	
	# 计算安全位置（将箱子推离玩家）
	var safe_distance = collision_shape_2d.shape.size.y + box.get_node("CollisionShape2D").shape.size.y
	var desired_box_pos = position - gravity_dir * safe_distance
	
	box.position = box.position.lerp(desired_box_pos, 0.3)
	
	velocity += gravity_dir * Consts.SPEED * 0.5


func check_box_on_head() -> void:
	var space_state = get_world_2d().direct_space_state
	var gravity_dir = get_gravity().normalized()
	var query = PhysicsRayQueryParameters2D.create(
		position,
		position - gravity_dir * 20
	)
	query.exclude = [self]
	query.collision_mask = 1
	
	var result = space_state.intersect_ray(query)
	if result and result.collider is CharacterBody2D and result.collider.is_in_group('pushable'):
		print('box on head')
	# 只在玩家向上移动时才影响箱子
		free_player_from_box(result.collider)

func set_gravity(new_gravity_direction: Vector2) -> void:
	print('set gravity')
	var gravity_instance = gravity_scene.instantiate()
	# gravity_instance.global_position = global_position
	gravity_instance.position = Vector2.ZERO
	gravity_instance.scale = Vector2(1, 1)
	gravity_instance.gravity_direction = new_gravity_direction
	# gravity_instance.top_level = true
	# 将重力场作为玩家的子节点，这样它会自动跟随玩家移动
	add_child(gravity_instance)
	
	# 创建一个计时器来控制重力场的生命周期
	var timer = get_tree().create_timer(second_jump_gravity_timer)
	
	# 当计时器结束时移除重力场
	timer.timeout.connect(func():
		if is_instance_valid(gravity_instance) and not gravity_instance.is_queued_for_deletion():
			gravity_instance.queue_free()
	)

func add_gravity_field(field: Node2D) -> void:
	active_gravity_gun_fields.append(field)

func can_second_jump() -> bool:
	return GameManager.is_skill_enabled("second_jump_enabled")

# 添加这个新函数来处理边角碰撞修正
func handle_corner_correction() -> void:
	if is_on_terrain():
		return
		
	var gravity_dir = get_gravity().normalized()
	var perpendicular_dir = Vector2(-gravity_dir.y, gravity_dir.x)
	var correction_distance = 8.0
	
	var space_state = get_world_2d().direct_space_state
	var movement_dir = velocity.project(perpendicular_dir).normalized()
	if movement_dir.length() == 0:
		return
		
	# 检测前方是否有墙
	var front_query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + movement_dir * correction_distance
	)
	front_query.exclude = [self]
	var front_result = space_state.intersect_ray(front_query)
	
	if front_result:
		# 检测四个方向: 上、下、左上、右上
		var offsets = [
			-gravity_dir * correction_distance,  # 上
			gravity_dir * correction_distance,   # 下
			-gravity_dir * correction_distance + perpendicular_dir * correction_distance,  # 左上/右上
			-gravity_dir * correction_distance - perpendicular_dir * correction_distance   # 右上/左上
		]
		
		for offset in offsets:
			var corner_query = PhysicsRayQueryParameters2D.create(
				global_position + offset,
				global_position + offset + movement_dir * correction_distance
			)
			corner_query.exclude = [self]
			var corner_result = space_state.intersect_ray(corner_query)
			
			# 如果某个方向有空间，进行位置修正
			if !corner_result:
				position += offset * 0.5
				print("应用边角修正: ", offset)
				return  # 找到可行的修正方向后立即返回

func hook(field: Node2D) -> void:
	is_hooking = true
	hook_target = field
	hook_timer = 0.0
	stuck_check_timer = 0.0
	last_hook_position = global_position  # 记录初始位置
	can_destroy = true
	has_double_jumped = false

func end_hook() -> void:
	is_hooking = false
	hook_target = null
	# can_move = true
	# 保持一定的动量
	velocity = velocity * 0.5
	can_destroy = false
	# print('hook end')


func spawn_after_image():
	var after_image = after_image_scene.instantiate()
	get_parent().add_child(after_image)
	
	# 设置残影的属性
	after_image.texture = animated_sprite_2d.sprite_frames.get_frame_texture(animated_sprite_2d.animation, animated_sprite_2d.frame)
	after_image.global_position = global_position
	after_image.rotation = animated_sprite_2d.rotation
	after_image.flip_h = animated_sprite_2d.flip_h
	after_image.scale = animated_sprite_2d.scale


func apply_force(collision_direction):
	# 反向作用力
	velocity += collision_direction

# 添加这个新函数来查找最近的重力场
func find_nearest_hookable_area() -> Node2D:
	if hookable_areas.is_empty():
		return null
		
	var nearest = null
	var shortest_distance = 200
	
	for area in hookable_areas:
		if not is_instance_valid(area):
			continue
			
		var distance = global_position.distance_to(area.global_position)
		if distance < shortest_distance:
			# 进行视线检测
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsRayQueryParameters2D.create(
				global_position,
				area.global_position
			)
			query.exclude = [self]
			
			var result = space_state.intersect_ray(query)
			if not result:
				shortest_distance = distance
				nearest = area
	
	return nearest

# 新增：当进入可钩爪区域检测范围
func _on_hookable_area_entered(area: Area2D) -> void:
	if area.is_in_group("hookable"):
		hookable_areas.append(area)

# 新增：当离开可钩爪区域检测范围
func _on_hookable_area_exited(area: Area2D) -> void:
	hookable_areas.erase(area)
