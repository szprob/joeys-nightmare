extends CharacterBody2D

#@onready var game_manager: Node = %game_manager
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var init_flip_h : bool = animated_sprite_2d.flip_h
#@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D



var jump_buffer_timer: float = 0.0  # 记录跳跃键按下的时间
var jump_hold_time: float = 0.0  # 记录跳跃键按住的时间
var is_jumping: bool = false  # 标记是否正在跳跃
var is_dropping: bool = false  # Track if the player is dropping through a platform
var drop_timer: float = 0.0  # Timer for disabling platform collision
# 保存原始的碰撞掩码
var original_collision_mask: int

func _ready():
	print('player ready:',position)
	#position = GameManager.game_state['current_respawn_point']
	print('set position ready,position:',position)
	original_collision_mask = collision_mask

func respawn():
	# 将角色位置设置为重生点
	position = GameManager.game_state['current_respawn_point']
	print("Character respawned at ", position)

# 开始跳跃的函数
func start_jump() -> void:
	velocity.y = Consts.JUMP_VELOCITY  # 初始跳跃速度
	jump_hold_time = 0.0  # 重置跳跃键按住时间
	is_jumping = true  # 标记为跳跃状态

# Start dropping through the platform
func remove_mask_temporarily(mask) -> void:
	# 移除mask为1的部分，保持其他部分不变
	collision_mask &= ~mask
	# 使用协程等待0.3秒，然后恢复原始的碰撞掩码
	await get_tree().create_timer(0.3).timeout
	collision_mask = original_collision_mask

# 检测玩家是否站在单向平台上
func is_on_one_way_platform() -> bool:
	if is_on_floor():
		var collision = get_last_slide_collision()
		if collision:
			var collider = collision.get_collider()
			# 检查 collider 是否具有 collision_layer 属性
			if collider and collider.has_method("get_collision_layer"):
				if collider.collision_layer & Consts.ONE_WAY_PLATFORM_LAYER != 0:
					return true
			# 如果是 TileMap，可能需要其他逻辑来判断
			elif collider is TileMap:
				# 在这里添加处理 TileMap 的逻辑
				# 例如，根据 TileMap 的某些属性或自定义数据来判断
				pass
	return false

func handle_move(delta,direction):
	# Add the gravity.
	if not is_on_floor():
		#print(collision_shape_2d.collision_mask)
		velocity += get_gravity() * delta
		jump_buffer_timer -= delta  # 在空中时，减少缓冲计时器
		
		# 如果玩家正在跳跃并且继续按住跳跃键，增加跳跃高度
		if is_jumping and Input.is_action_pressed("jump"):
			jump_hold_time += delta
			# 增加跳跃速度，直到达到最大值或超过允许的按住时间
			if jump_hold_time < Consts.MAX_JUMP_HOLD_TIME and velocity.y > Consts.MAX_JUMP_VELOCITY:
				velocity.y = lerp(velocity.y, Consts.MAX_JUMP_VELOCITY, delta * 2)  # 平滑增加跳跃高度
		else:
			is_jumping = false  # 玩家松开跳跃键，停止跳跃高度增加
		
	else :
		# 角色刚落地时，检查是否在缓冲时间内按下过跳跃键
		if jump_buffer_timer > 0:
			start_jump()  # 如果缓冲计时器大于0，则自动跳跃
			jump_buffer_timer = 0  # 跳跃后重置计时器
		
	
	# Handle jump input with buffering
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			# 如果按住下键并且在平台上，触发下落平台逻辑
			if Input.is_action_pressed("down") and is_on_one_way_platform():
				remove_mask_temporarily(2)
			else:
				start_jump()  # 正常跳跃
		else:
			jump_buffer_timer = Consts.JUMP_BUFFER_TIME  # 记录跳跃键按下的时间以便缓冲
	
	# Handle movement
	if direction:
		velocity.x = direction * Consts.SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, Consts.SPEED)
	move_and_slide()
	
func handle_animation(delta,direction):
	# Flip sprite based on movement direction 
	if direction > 0 :
		animated_sprite_2d.flip_h = init_flip_h
	elif direction < 0 :
		animated_sprite_2d.flip_h = !init_flip_h
	
	# paly animations
	if is_on_floor():
		if direction == 0 :
			animated_sprite_2d.play('idle')
		else :
			animated_sprite_2d.play('move')
	else:
		animated_sprite_2d.play(('jump'))
	
func handle_command(delta):
	if Input.is_action_pressed("reload"):
		print("reload")
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	handle_command(delta)
	var direction := Input.get_axis("left", "right")
	handle_move(delta,direction)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	handle_animation(delta,direction)
