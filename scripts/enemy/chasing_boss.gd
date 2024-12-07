extends CharacterBody2D

# 添加计时器和目标位置变量
@export var state_timer: float = 0.0
@export var init_wait_time: float = 1.5
@export var idle_duration: float = 0.3
@export var dash_speed: float = 200.0
@export var player: Node2D
@export var time_enable_attack_collision: float = 0.75
@export var limit_y_offset_top: int = 50
@export var limit_y_offset_bottom: int = 5

# 添加状态枚举
enum State {IDLE, ATTACKING, DASH, INIT}
var current_state = State.INIT
var target_position: Vector2
var timer: Timer # 攻击碰撞启用计时器
var timer_audio: Timer # audio 
var init_timer: Timer # 初始化计时器
var origin_scale_x 
var idle_direction: Vector2
var dash_direction: Vector2
var attack_direction: Vector2
var direction2player
var current_camera: Camera2D
var limit_top: int
var limit_bottom: int
var is_die: bool = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_collision: CollisionShape2D = $kill_zone/CollisionShape2D2
@onready var audio_non_hit: AudioStreamPlayer2D = $audio_non_hit
@onready var audio_hit: AudioStreamPlayer2D = $audio_hit



func _ready():
	# player
	player = get_tree().get_first_node_in_group("player")
	global_position = player.global_position + Vector2(-50, -50)
	# camera
	current_camera = get_tree().get_first_node_in_group("camera")
	# die 
	GameManager.die_requested.connect(_on_die_requested)

	animated_sprite.animation_finished.connect(_on_animation_finished)
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timeout)
	timer.wait_time = time_enable_attack_collision
	timer.one_shot = true

	timer_audio = Timer.new()
	add_child(timer_audio)
	timer_audio.timeout.connect(_on_timeout_audio)
	timer_audio.wait_time = time_enable_attack_collision+0.05
	timer_audio.one_shot = true

	init_timer = Timer.new()
	add_child(init_timer)
	init_timer.timeout.connect(_on_init_timeout)
	init_timer.wait_time = init_wait_time
	init_timer.one_shot = true
	init_timer.start()

	origin_scale_x = scale.x
	# idle_direction = (player.global_position - global_position).normalized()
	# scale.x = origin_scale_x if idle_direction.x < 0 else -origin_scale_x
	

func _on_die_requested():
	is_die = true

func _on_init_timeout():
	change_state(State.IDLE)

func _on_timeout():
	attack_collision.disabled = false

func _on_timeout_audio():
	if not is_die:
		audio_non_hit.play()
	else:
		audio_hit.play()

# 添加动画完成的回调函数
func _on_animation_finished():
	if current_state == State.ATTACKING:
		change_state(State.IDLE)

func _physics_process(delta: float) -> void:
	limit_top = current_camera.limit_top + limit_y_offset_top
	limit_bottom = current_camera.limit_bottom - limit_y_offset_bottom
	
	state_timer += delta
	match current_state:
		State.IDLE:
			if not animated_sprite.is_playing():
				animated_sprite.play("idle")
			if state_timer >= idle_duration:
				# if player.global_position.y > limit_top and player.global_position.y < limit_bottom:
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
			timer_audio.start()
		State.DASH:
			direction2player = (player.global_position - global_position).normalized()
			scale.x = origin_scale_x if direction2player.x > 0 else -origin_scale_x
			target_position = player.global_position
			if target_position.y < limit_top :
				target_position.y = limit_top

			dash_direction = (target_position - global_position).normalized()
			# scale.x = origin_scale_x if dash_direction.x > 0 else -origin_scale_x
			velocity = dash_direction * dash_speed
