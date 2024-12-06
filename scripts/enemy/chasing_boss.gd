extends CharacterBody2D

# 添加计时器和目标位置变量
@export var state_timer: float = 0.0
@export var idle_duration: float = 3.0
@export var dash_speed: float = 180.0
@export var player: Node2D
@export var time_enable_attack_collision: float = 0.8

# 添加状态枚举
enum State {IDLE, ATTACKING, DASH}
var current_state = State.IDLE
var target_position: Vector2
var timer: Timer
var origin_scale_x 
var idle_direction: Vector2
var dash_direction: Vector2
var attack_direction: Vector2
var direction2player
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_collision: CollisionShape2D = $kill_zone/CollisionShape2D2

func _ready():
	player = get_tree().get_first_node_in_group("player")
	global_position = player.global_position + Vector2(-200, -100)
	
	
	animated_sprite.animation_finished.connect(_on_animation_finished)
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timeout)
	timer.wait_time = time_enable_attack_collision
	timer.one_shot = true

	origin_scale_x = scale.x
	# idle_direction = (player.global_position - global_position).normalized()
	# scale.x = origin_scale_x if idle_direction.x < 0 else -origin_scale_x
	change_state(State.IDLE)

func _on_timeout():
	attack_collision.disabled = false

# 添加动画完成的回调函数
func _on_animation_finished():
	if current_state == State.ATTACKING:
		change_state(State.IDLE)

func _physics_process(delta: float) -> void:
	state_timer += delta
	match current_state:
		State.IDLE:
			if not animated_sprite.is_playing():
				animated_sprite.play("idle")
			if state_timer >= idle_duration:
				change_state(State.DASH)
		State.ATTACKING:
			pass
		State.DASH:
			if not animated_sprite.is_playing():
				animated_sprite.play("dash")
			var direction = (target_position - global_position).normalized()
			velocity = direction * dash_speed
			# animated_sprite.flip_h = direction.x < 0
			# animated_sprite.rotation = direction.angle() + (PI as float if animated_sprite.flip_h else 0.0)
			if global_position.distance_to(target_position) < 10:
				global_position = target_position
				change_state(State.ATTACKING)
	move_and_slide()

func change_state(new_state: State) -> void:
	current_state = new_state
	state_timer = 0.0
	attack_collision.disabled = true

	match new_state:
		State.IDLE:
			velocity = Vector2.ZERO
		State.ATTACKING:
			velocity = Vector2.ZERO
			animated_sprite.play("attacking")
			timer.start()
		State.DASH:
			direction2player = (player.global_position - global_position).normalized()
			scale.x = origin_scale_x if direction2player.x > 0 else -origin_scale_x
			target_position = player.global_position
			dash_direction = (target_position - global_position).normalized()
			# scale.x = origin_scale_x if dash_direction.x > 0 else -origin_scale_x
			velocity = dash_direction * dash_speed
