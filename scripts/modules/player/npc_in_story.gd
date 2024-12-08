extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
const SPEED = 100.0

# 新增状态控制
var can_move = true
var player_state = 'idle'

func _physics_process(delta: float) -> void:
	# 根据状态处理移动
	if not can_move:
		if player_state == 'auto_run':
			# 自动向右奔跑
			velocity.x = SPEED
			
			
			velocity.y += get_gravity().y * delta
			animated_sprite.flip_h = velocity.x < 0
				
			move_and_slide()
		else:
			# 其他状态(如idle)则停止移动
			velocity = Vector2.ZERO
		return
	
	# 默认状态:停止移动
	velocity = Vector2.ZERO
	move_and_slide()

# 开始自动奔跑
func start_auto_run() -> void:
	can_move = false
	player_state = 'auto_run'

# 停止自动奔跑
func stop_auto_run() -> void:
	can_move = true
	player_state = 'idle'
