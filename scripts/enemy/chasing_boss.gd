extends CharacterBody2D

# 添加计时器和目标位置变量
@export var state_timer: float = 0.0
@export var idle_duration: float = 5.0
@export var prepare_duration: float = 3.0
@export var dash_speed: float = 300.0
@export var player: Node2D
@export var prepare_move_speed: float = 10.0

# 添加状态枚举
enum State {IDLE, PREPARING, DASH}
var current_state = State.IDLE
var target_position: Vector2

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	global_position = player.global_position + Vector2(-200, -100)
	change_state(State.IDLE)

func _physics_process(delta: float) -> void:
	state_timer += delta
	
	match current_state:
		State.IDLE:
			animated_sprite.play("idle")
			if state_timer >= idle_duration:
				change_state(State.PREPARING)
			var idle_direction = (player.global_position - global_position).normalized()
			animated_sprite.flip_h = idle_direction.x < 0
			# animated_sprite.rotation = idle_direction.angle() + (PI as float if animated_sprite.flip_h else 0.0)
		
		State.PREPARING:
			animated_sprite.play("preparing")
			if state_timer >= prepare_duration:
				change_state(State.DASH)
		State.DASH:
			animated_sprite.play("dash")
			var direction = (target_position - global_position).normalized()
			velocity = direction * dash_speed
			animated_sprite.flip_h = direction.x < 0
			animated_sprite.rotation = direction.angle() + (PI as float if animated_sprite.flip_h else 0.0)
			if global_position.distance_to(target_position) < 10:
				change_state(State.IDLE)
	move_and_slide()

func change_state(new_state: State) -> void:
	current_state = new_state
	state_timer = 0.0
	
	match new_state:
		State.IDLE:
			velocity = Vector2.ZERO
			animated_sprite.rotation = 0
		State.PREPARING:
			# 记录玩家位置作为冲刺目标
			target_position = player.global_position
			var prepare_direction = (target_position - global_position).normalized()
			velocity = prepare_direction * prepare_move_speed
			animated_sprite.flip_h = prepare_direction.x < 0
			animated_sprite.rotation = prepare_direction.angle() + (PI as float if animated_sprite.flip_h else 0.0)
		State.DASH:
			pass
