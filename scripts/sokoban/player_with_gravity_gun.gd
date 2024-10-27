extends CharacterBody2D

#@onready var game_manager: Node = %game_manager
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# shooting
@export var cooldown = 0.25
@export var bullet_scene: PackedScene
var can_shoot = true
var facing_direction = 1

var jump_buffer_timer: float = 0.0 # 记录跳跃键按下的时间
var jump_hold_time: float = 0.0 # 记录跳跃键按住的时间
var is_jumping: bool = false # 标记是否正在跳跃
var is_dropping: bool = false # Track if the player is dropping through a platform
var drop_timer: float = 0.0 # Timer for disabling platform collision
# 保存原始的碰撞掩码
var original_collision_mask: int
var default_pos = Vector2(0, 0)


func _ready():
	#position = Vector2(300,-100)
	default_pos = position
	print('default pos', default_pos)
	#GameManager.load_game_state()
	#position = GameManager.game_state['current_respawn_point']
	#original_collision_mask = collision_mask
	$GunCooldown.wait_time = cooldown
	print(get_gravity())
func respawn():
	# 将角色位置设置为重生点
	#position = GameManager.game_state['current_respawn_point']
	velocity = Vector2.ZERO
	position = default_pos
	# 重置所有状态
	is_jumping = false
	is_dropping = false
	jump_buffer_timer = 0.0
	jump_hold_time = 0.0

	pass

# 开始跳跃的函数
func start_jump() -> void:
	print('start jump')
	# 获取重力方向的单位向量
	var gravity_dir = get_gravity().normalized()
	print('gravity dir', gravity_dir)
	# 跳跃方向与重力方向相反
	velocity -= gravity_dir * abs(Consts.JUMP_VELOCITY)
	jump_hold_time = 0.0 # 重置跳跃键按住时间
	is_jumping = true # 标记为跳跃状态
	
func shoot(Input) -> void:
	var shoot_direction = Vector2(facing_direction, 0)
	if not can_shoot:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	if not (Input.is_action_pressed('up') or Input.is_action_pressed('down') or
			Input.is_action_pressed('left') or Input.is_action_pressed('right')):
		b.start(position + Vector2(0, -8), shoot_direction)
	else:
		shoot_direction = Vector2(0, 0)
		if Input.is_action_pressed("ui_up"):
			shoot_direction.y = -1
		if Input.is_action_pressed("ui_down"):
			shoot_direction.y = 1
		if Input.is_action_pressed("ui_left"):
			shoot_direction.x = -1
		if Input.is_action_pressed("ui_right"):
			shoot_direction.x = 1
		b.start(position + Vector2(0, -8), shoot_direction)

# Start dropping through the platform
func remove_mask_temporarily(mask) -> void:
	# 移除mask为1的部分，保持其他部分不变
	collision_mask &= ~mask
	# 使用协程等待0.3秒，然后恢复原始的碰撞掩码
	await get_tree().create_timer(0.3).timeout
	collision_mask = original_collision_mask

# 检测玩家是否站在单向平台上
func is_on_one_way_platform() -> bool:
	if is_on_terrain():
		var collision = get_last_slide_collision()
		if collision:
			var collider = collision.get_collider()
			# 检查 collider 是否具有 collision_layer 属性
			if collider and collider.has_method("get_collision_layer") and not (collider is TileMap):
				if collider.collision_layer & Consts.ONE_WAY_PLATFORM_LAYER != 0:
					return true
			# 如果是 TileMap，可能需要其他逻辑来判断
			elif collider is TileMap:
				# 在这里添加处理 TileMap 的逻辑
				# 例如，根据 TileMap 的某些属性或自定义数据来判断
				pass
	return false

func _physics_process(delta: float) -> void:
	# Add the gravity.

	if not is_on_terrain():
		#print(collision_shape_2d.collision_mask)
		velocity += get_gravity() * delta
		jump_buffer_timer -= delta # 在空中时，减少缓冲计时器
		# 如果玩家正在跳跃并且继续按住跳跃键，增加跳跃高度
		# FIXME: 没有大跳
		if is_jumping and Input.is_action_pressed('jump'):
			print('is jumping and jump pressed', jump_hold_time)
			jump_hold_time += delta
			if jump_hold_time < Consts.MAX_JUMP_HOLD_TIME:
				var gravity_dir = get_gravity().normalized()
				# 计算当前速度在重力方向上的投影
				var velocity_projection = velocity.project(gravity_dir).length()
				print('velocity projection', velocity_projection)
				if abs(velocity_projection) < abs(Consts.MAX_JUMP_VELOCITY):
					# 计算目标速度向量（与重力方向相反）
					var target_velocity = -gravity_dir * abs(Consts.MAX_JUMP_VELOCITY)
					print('target velocity', target_velocity)
					# 在重力方向上进行lerp
					velocity = lerp(velocity, target_velocity, delta * 2)
		else:
			is_jumping = false # 玩家松开跳跃键，停止跳跃高度增加
		
	else:
		# 角色刚落地时，检查是否在缓冲时间内按下过跳跃键
		if jump_buffer_timer > 0:
			start_jump() # 如果缓冲计时器大于0，则自动跳跃
			jump_buffer_timer = 0 # 跳跃后重置计时器


	# Handle jump input with buffering
	if Input.is_action_just_pressed("jump"):
		# print('is on terrain', is_on_terrain()
		if is_on_terrain():
			# 如果按住下键并且在平台上，触发下落平台逻辑
			if Input.is_action_pressed("down") and is_on_one_way_platform():
				print("Player is on a one-way platform")
				remove_mask_temporarily(2)
			else:
				start_jump() # 正常跳跃
			# start_jump()
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
	if Input.is_action_pressed("shoot"):
		print('shooting')
		shoot(Input)
	
	# TODO: fix this on different gravity direction
	# Flip sprite based on movement direction 
	if direction.x > 0:
		animated_sprite_2d.flip_h = false
	elif direction.x < 0:
		animated_sprite_2d.flip_h = true
		
	# Flip sprite based on gravity dirction
	filp_player_sprite()

	# paly animations
	if is_on_terrain():
		if direction.x == 0 and direction.y == 0:
			animated_sprite_2d.play('idle')
		else:
			animated_sprite_2d.play('move')
	else:
		animated_sprite_2d.play(('jump'))
		

	# Handle movement
	if direction:
		# 根据重力方向调整移动
		if abs(get_gravity().y) > abs(get_gravity().x):
			# 垂直重力情况（向上或向下）
			velocity.x = direction.x * Consts.SPEED
		else:
			# 水平重力情况（向左或向右）
			velocity.y = direction.y * Consts.SPEED # 使用 direction.y 来控制上下移动
	else:
		if abs(get_gravity().y) > abs(get_gravity().x):
			velocity.x = move_toward(velocity.x, 0, Consts.SPEED)
		else:
			velocity.y = move_toward(velocity.y, 0, Consts.SPEED)
	
	move_and_slide()
	# push boxes
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is CharacterBody2D and collider.is_in_group('pushable'):
			collider.push(Vector2(direction))
	
	# print player status
	# print(get_gravity())
	
	
func update_face_direction(direction):
	if direction != 0:
		facing_direction = direction


func _on_gun_cooldown_timeout() -> void:
	can_shoot = true
	pass # Replace with function body.


func is_on_terrain() -> bool:
	# 根据重力方向设置射线方向
	var gravity_dir = get_gravity().normalized()
	ray_cast_2d.target_position = gravity_dir * 18
	ray_cast_2d.enabled = true


	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()

		if collider is TileMapLayer or collider is StaticBody2D:
			# print('is on tilemap')
			return true
			
	# print('not on tilemap')
	return false

func filp_player_sprite():
	# flip palyer sprite based on gravity direction

	var gravity = get_gravity().normalized()
	var angle = gravity.angle() - PI / 2 # 加90度使角色垂直于重力方向
	animated_sprite_2d.rotation = angle
	collision_shape_2d.rotation = angle
