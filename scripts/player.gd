extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var jump_buffer_timer: float = 0.0  # 记录跳跃键按下的时间
var jump_hold_time: float = 0.0  # 记录跳跃键按住的时间
var is_jumping: bool = false  # 标记是否正在跳跃
var is_dropping: bool = false  # Track if the player is dropping through a platform
var drop_timer: float = 0.0  # Timer for disabling platform collision


# 开始跳跃的函数
func start_jump() -> void:
	velocity.y = Globals.JUMP_VELOCITY  # 初始跳跃速度
	jump_hold_time = 0.0  # 重置跳跃键按住时间
	is_jumping = true  # 标记为跳跃状态

# Start dropping through the platform
func drop_through_platform() -> void:
	pass 

# 检测玩家是否站在单向平台上
func is_on_one_way_platform() -> bool:
	# Check for collisions
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("OneWayPlatform"):
			return true 
	return false 

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		#print(collision_shape_2d.collision_mask)
		velocity += get_gravity() * delta
		jump_buffer_timer -= delta  # 在空中时，减少缓冲计时器
		
		# 如果玩家正在跳跃并且继续按住跳跃键，增加跳跃高度
		if is_jumping and Input.is_action_pressed("jump"):
			jump_hold_time += delta
			# 增加跳跃速度，直到达到最大值或超过允许的按住时间
			if jump_hold_time < Globals.MAX_JUMP_HOLD_TIME and velocity.y > Globals.MAX_JUMP_VELOCITY:
				velocity.y = lerp(velocity.y, Globals.MAX_JUMP_VELOCITY, delta * 2)  # 平滑增加跳跃高度
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
				print(collision_mask)
			else:
				start_jump()  # 正常跳跃
		else:
			jump_buffer_timer = Globals.JUMP_BUFFER_TIME  # 记录跳跃键按下的时间以便缓冲
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	
	# Flip sprite based on movement direction 
	if direction >0 :
		animated_sprite_2d.flip_h = false
	elif direction < 0 :
		animated_sprite_2d.flip_h = true
	
	# paly animations
	if is_on_floor():
		if direction == 0 :
			animated_sprite_2d.play('idle')
		else :
			animated_sprite_2d.play('move')
	else:
		animated_sprite_2d.play(('jump'))
	# Handle movement
	if direction:
		velocity.x = direction * Globals.SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, Globals.SPEED)

	move_and_slide()
