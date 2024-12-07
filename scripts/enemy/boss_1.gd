extends Area2D

var player
var areas: Array[Area2D] = []
var current_area_index
var ball 
var particles_scene
var current_particles

enum State {
	DASH,
	DIE,
	IDLE,
	SHOOT,
	STUN
}

var state = State.IDLE
var idle_timer = 0 
var target_position = Vector2.ZERO
var next_position = Vector2.ZERO
var do_detect=true # 是否检测碰撞
var velocity = Vector2.ZERO  # 声明 velocity 变量
var origin_scale_x
var timer  # 射击之后创建ball的时间
var can_move_timer

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var idle_time = 2 
@export var can_move_time = 0.5
@export var dash_speed: float = 200.0
@export var do_attack:bool = true



func _ready():
	
	particles_scene = preload("res://scenes/modules/ui/collision_particles.tscn")
	current_particles = particles_scene.instantiate()
	current_particles.emitting = false
	add_child(current_particles)
	ball = preload("res://scenes/enemy/ball.tscn")
	player = get_tree().get_first_node_in_group("player")
	for child in get_children():
		if child is Area2D:
			areas.append(child)
	
	# 加载当前区域
	current_area_index = GameManager.game_state['boss']['boos1']['current_area_index']
	global_position = areas[current_area_index].global_position

	body_entered.connect(on_body_entered)
	origin_scale_x = scale.x
	change_state(State.IDLE)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	can_move_timer = Timer.new()
	can_move_timer.one_shot = true
	add_child(can_move_timer)
	can_move_timer.timeout.connect(_on_can_move_timeout)


func _physics_process(delta):
	match state:
		State.IDLE:
			handle_idle_state(delta)
		State.DASH:
			handle_dash_state(delta)

func handle_idle_state(delta):
	idle_timer += delta
	if idle_timer >= idle_time and do_attack:
		change_state(State.SHOOT)

# shoot
func _on_timer_timeout() -> void:
	var ball_instance = ball.instantiate()
	var offset = Vector2(70, 0) if player.global_position.x > global_position.x else Vector2(-70, 0)
	ball_instance.global_position = global_position + offset
	ball_instance.set_target(player)
	get_tree().current_scene.add_child(ball_instance)
	# change_state(State.DASH)

func _on_can_move_timeout():
	player.set_can_move(true)


func handle_dash_state(delta):
	var dash_direction = (next_position - global_position).normalized()
	velocity += dash_direction * dash_speed * delta
	if velocity.length() > dash_speed:
		velocity = dash_direction * dash_speed

	global_position += velocity * delta
	
	if global_position.distance_to(next_position) < 10:
		global_position = next_position
		change_state(State.IDLE)

func change_scale(face_position):
	if face_position.x > global_position.x:
		scale.x = origin_scale_x
	else:
		scale.x = -origin_scale_x



func change_state(new_state):
	state = new_state
	idle_timer = 0 
	do_detect = (new_state in [State.IDLE, State.SHOOT])

	match new_state:
		State.IDLE:
			change_scale(player.global_position)
			animated_sprite.play("idle")
		State.SHOOT:
			change_scale(player.global_position)
			animated_sprite.play("shoot")
			audio_player.play()
			timer.start()
		State.DASH:
			if current_area_index + 1 >= areas.size():
				change_state(State.DIE)
				return
			current_area_index += 1
			next_position = areas[current_area_index].global_position
			change_scale(next_position)
			animated_sprite.play("dash")
		State.STUN:
			animated_sprite.play("stun")
		State.DIE:
			animated_sprite.play("die")


# 定义 on_body_entered 函数
func on_body_entered(body):
	if body.is_in_group("player") and do_detect:
		
		# 添加振动效果
		GameManager.camera_shake_requested.emit(5, 0.2)
		# 给玩家一个反向作用力
		if body.has_method("apply_force"):
			var collision_direction = (body.global_position - global_position).normalized()
			body.apply_force(collision_direction * 700)
			body.set_can_move(false,'jump')
			can_move_timer.start(can_move_time)
		change_state(State.STUN)
		create_collision_effect(body.global_position)


func _on_animation_finished():
	match animated_sprite.animation:
		"stun":
			change_state(State.DASH)
		"shoot":
			change_state(State.IDLE)
		"die":
			queue_free()

func create_collision_effect(pos: Vector2):
	if current_particles:
		current_particles.global_position = pos
		current_particles.restart()
		current_particles.emitting = true