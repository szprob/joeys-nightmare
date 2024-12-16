extends Area2D

var player
var areas: Array[Area2D] = []
var pos_list: Array[Vector2] = []
var current_area_index
var ball 
var particles_scene
var current_particles

enum State {
	DASH,
	DIE,
	IDLE,
	SHOOT,
	STUN,
	CHANGE,
	ACHANGE,
}

var state = State.IDLE
var idle_timer = 0 
var target_position = Vector2.ZERO
var next_position = Vector2.ZERO
var do_detect=true # 是否检测碰撞
var velocity = Vector2.ZERO  # 声明 velocity 变量
var timer  # 射击之后创建ball的时间
var can_move_timer
var dash_direction
var sign_scale_x
var is_init: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var collision_shape2: CollisionShape2D = $Area2D/CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var coll_audio: AudioStreamPlayer2D = $coll_audio

@export var can_destroy: bool = false
@export var idle_time = 2 
@export var can_move_time = 0.5
@export var dash_speed: float = 400.0
@export var do_attack:bool = true
@export var next_scene_file_path: String = "res://scenes/day/game/game.tscn"
@export var transition_scene: String = "res://scenes/modules/checkpoints/transition.tscn"  # 添加过渡场景路径
@export var teleport_type: String = "dream2day"
# 残影
@export var after_image_scene: PackedScene
@export var after_image_interval: float = 0.1
var after_image_timer: float = 0.0

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
	pos_list = []
	for area in areas:
		pos_list.append(area.global_position)
	collision_shape2.disabled = true
	# can_destroy = false
	# 加载当前区域
	current_area_index = GameManager.game_state['boss']['boos1']['current_area_index']
	global_position = pos_list[current_area_index]

	body_entered.connect(on_body_entered)
	
	animated_sprite.animation_finished.connect(_on_animation_finished)
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	
	can_move_timer = Timer.new()
	can_move_timer.one_shot = true
	add_child(can_move_timer)
	can_move_timer.timeout.connect(_on_can_move_timeout)

	sign_scale_x = 1
	is_init = true
	change_state(State.IDLE)


func spawn_after_image(delta):
	after_image_timer += delta
	if after_image_timer>=after_image_interval:	
		after_image_timer = 0.0
		
		# 设置残影的属性
		var after_image = after_image_scene.instantiate()
	#if sign_scale_x == 1:
		after_image.texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
		after_image.rotation = animated_sprite.rotation
		after_image.scale.x = scale.x * 1.5
		after_image.scale.y = scale.y * 1.5
		if sign_scale_x == 1:
			after_image.flip_h=true
		else:
			after_image.flip_h=false
		after_image.global_position = animated_sprite.global_position
		get_parent().add_child(after_image)

func _physics_process(delta):
	if !is_init:
		return
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
	var offset = Vector2(50, 0) if sign_scale_x == 1 else Vector2(-50, 0)
	ball_instance.global_position = global_position + offset
	ball_instance.set_target(player)
	get_tree().current_scene.add_child(ball_instance)
	# change_state(State.DASH)

func _on_can_move_timeout():
	player.set_can_move(true)


func handle_dash_state(delta):
	dash_direction = (next_position - global_position).normalized()
	velocity += dash_direction * dash_speed * delta
	if velocity.length() > dash_speed:
		velocity = dash_direction * dash_speed

	global_position += velocity * delta
	rotation = dash_direction.angle()
	if global_position.distance_to(next_position) < 10:
		global_position = next_position
		change_state(State.ACHANGE)

func change_face_direction_and_position(pos):
	dash_direction = (pos - global_position).normalized()


	if sign(dash_direction.x) >0 :
		animated_sprite.flip_h = false
		sign_scale_x = 1
	else:
		animated_sprite.flip_h = true
		sign_scale_x = -1
	
	if state == State.DASH:
		animated_sprite.flip_h = false
		sign_scale_x = 1



func change_state(new_state):
	rotation = 0
	state = new_state
	idle_timer = 0 
	collision_shape2.disabled = true
	do_detect = (new_state in [State.IDLE, State.SHOOT])
	can_destroy = false
	
	match new_state:
		State.IDLE:
			GameManager.game_state['boss']['boos1']['current_area_index'] = current_area_index
			change_face_direction_and_position(player.global_position)
			animated_sprite.play("idle")
		State.SHOOT:
			change_face_direction_and_position(player.global_position)
			animated_sprite.play("shoot")
			audio_player.play()
			timer.start()
		State.CHANGE:
			if current_area_index + 1 >= pos_list.size():
				change_state(State.DIE)
				return
			animated_sprite.play("change")
		State.ACHANGE:
			change_face_direction_and_position(player.global_position)
			animated_sprite.play_backwards("change")
		State.DASH:
			can_destroy = true
			collision_shape2.disabled = false
			current_area_index += 1
			next_position = pos_list[current_area_index]
			change_face_direction_and_position(next_position)
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
			body.apply_force(collision_direction * 1000)
			body.set_can_move(false,'jump')
			can_move_timer.start(can_move_time)
		change_state(State.STUN)
		create_collision_effect(body.global_position)
		coll_audio.play()


func _on_animation_finished():
	match state:
		State.STUN:
			change_state(State.CHANGE)
		State.SHOOT:
			change_state(State.IDLE)
		State.CHANGE:
			change_state(State.DASH)
		State.ACHANGE:
			change_state(State.IDLE)
		State.DIE:
			GameManager.game_state['target_scene'] = next_scene_file_path
			GameManager.game_state['teleport_type'] = teleport_type
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_file(transition_scene)

func create_collision_effect(pos: Vector2):
	if current_particles:
		current_particles.global_position = pos
		current_particles.restart()
		current_particles.emitting = true
