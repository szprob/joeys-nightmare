extends CharacterBody2D


const SPEED = 125.0
const JUMP_VELOCITY = -200.0  # 初始跳跃速度
const MAX_JUMP_HOLD_TIME = 0.3  # 玩家按住跳跃键的最大时间
const MAX_JUMP_VELOCITY = -350.0  # 最大跳跃速度（跳得越高，Y值越小）
const JUMP_BUFFER_TIME = 0.15  # 跳跃缓冲时间，0.3秒

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var jump_buffer_timer: float = 0.0  # 记录跳跃键按下的时间
var jump_hold_time: float = 0.0  # 记录跳跃键按住的时间
var is_jumping: bool = false  # 标记是否正在跳跃

# 开始跳跃的函数
func start_jump() -> void:
	velocity.y = JUMP_VELOCITY  # 初始跳跃速度
	jump_hold_time = 0.0  # 重置跳跃键按住时间
	is_jumping = true  # 标记为跳跃状态


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		jump_buffer_timer -= delta  # 在空中时，减少缓冲计时器
		
		# 如果玩家正在跳跃并且继续按住跳跃键，增加跳跃高度
		if is_jumping and Input.is_action_pressed("jump"):
			jump_hold_time += delta
			# 增加跳跃速度，直到达到最大值或超过允许的按住时间
			if jump_hold_time < MAX_JUMP_HOLD_TIME and velocity.y > MAX_JUMP_VELOCITY:
				velocity.y = lerp(velocity.y, MAX_JUMP_VELOCITY, delta * 2)  # 平滑增加跳跃高度
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
			start_jump()  # 如果玩家在地面，直接开始跳跃
		else:
			jump_buffer_timer = JUMP_BUFFER_TIME  # 记录跳跃键按下的时间以便缓冲
			
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
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
