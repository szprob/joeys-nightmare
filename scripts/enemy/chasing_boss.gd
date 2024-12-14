extends CharacterBody2D

# 添加计时器和目标位置变量
@export var state_timer: float = 0.0
@export var init_wait_time: float = 1.5
@export var idle_duration: float = 0.3
@export var dash_speed: float = 200.0
@export var player: Node2D
@export var time_enable_attack_collision: float = 0.9
@export var limit_y_offset_top: int = 50
@export var limit_y_offset_bottom: int = 5
@export var can_destroy: bool = true


# shadow/ after image / 残影
@export var after_image_scene: PackedScene
var after_image_timer: float = 0.0
var after_image_interval: float = 0.05

# 添加状态枚举
enum State {IDLE, ATTACKING, DASH, INIT,ATT_DASH}
var current_state = State.INIT
var target_position: Vector2
var timer: Timer # 攻击碰撞启用计时器
var timer_audio: Timer # audio 
var timer_audio_att_dash: Timer # audio 
var init_timer: Timer # 初始化计时器
var origin_scale_x 
var idle_direction: Vector2
var dash_direction: Vector2
var dash_vec: Vector2
var attack_direction: Vector2
var direction2player
var current_camera: Camera2D
var limit_top: int
var limit_bottom: int
var is_die: bool = false
var idx : int = 0 
var att_dash_t  = 0 
var prepare_dash: bool = false
var decelerate = false
var is_init: bool = false
var sign_scale_x: int = 1

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_collision: CollisionPolygon2D = $kill_zone/CollisionPolygon2D
@onready var attack_collision_att_dash: CollisionShape2D = $kill_zone/CollisionShape2D3
@onready var audio_non_hit: AudioStreamPlayer2D = $audio_non_hit
@onready var audio_hit: AudioStreamPlayer2D = $audio_hit



func _ready():
	# player
	await get_tree().create_timer(0.1).timeout
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
	timer_audio.wait_time = time_enable_attack_collision
	timer_audio.one_shot = true

	init_timer = Timer.new()
	add_child(init_timer)
	init_timer.timeout.connect(_on_init_timeout)
	init_timer.wait_time = init_wait_time
	init_timer.one_shot = true
	init_timer.start()

	origin_scale_x = 1
	# idle_direction = (player.global_position - global_position).normalized()
	# scale.x = origin_scale_x if idle_direction.x < 0 else -origin_scale_x

	is_init = true
	
func spawn_after_image(delta):
	after_image_timer += delta
	if after_image_timer>=after_image_interval:	
		after_image_timer = 0.0
		
		# 设置残影的属性
		var after_image = after_image_scene.instantiate()
	#if sign_scale_x == 1:
		after_image.texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
		after_image.rotation = animated_sprite.rotation
		if sign_scale_x == 1:
			after_image.flip_h=true
		else:
			after_image.flip_h=false
		after_image.global_position = animated_sprite.global_position + Vector2(-11, -56)
		#else:
			#after_image.texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
			#after_image.rotation = animated_sprite.rotation
			## after_image.flip_h=animated_sprite.flip_h
			#after_image.global_position = global_position - Vector2(-110,100)
			#after_image.scale.x = -sign_scale_x
		# print("after_image.scale.x",after_image.scale.x)
		# print("scale.x",scale.x)
		# print("after_image.global_position",after_image.global_position)
		# print("global_position",global_position)
			
		# 	# after_image.scale.x = -scale.x*5
		# 	after_image.global_position = global_position- Vector2(-110,100)


	# after_image.scale.y = scale.y * 5 
	# after_image.scale.x = scale.x * 5 
		get_parent().add_child(after_image)



func _on_die_requested():
	is_die = true
	audio_hit.play()

func _on_init_timeout():
	change_state(State.IDLE)

func _on_timeout():
	attack_collision.disabled = false

func _on_timeout_audio():
	audio_non_hit.play()



# 添加动画完成的回调函数
func _on_animation_finished():
	if current_state == State.ATTACKING:
		change_state(State.IDLE)
	elif current_state == State.ATT_DASH:
		change_state(State.IDLE)


func _physics_process(delta: float) -> void:
	if not is_init:
		return
		
	limit_top = current_camera.limit_top + limit_y_offset_top
	limit_bottom = current_camera.limit_bottom - limit_y_offset_bottom
	
	state_timer += delta
	match current_state:
		State.IDLE:
			if not animated_sprite.is_playing():
				animated_sprite.play("idle")
			if state_timer >= idle_duration:
				# if player.global_position.y > limit_top and player.global_position.y < limit_bottom:
				if idx % 4 > 0:
					change_state(State.DASH)
				else:
					change_state(State.ATT_DASH)
		State.ATTACKING:
			pass
		State.DASH:
			
			if not animated_sprite.is_playing():
				animated_sprite.play("dash")
			if global_position.distance_to(target_position) < 10:
				global_position = target_position
				change_state(State.ATTACKING)
		State.ATT_DASH:
			# print("scale.x",scale.x)
			if not animated_sprite.is_playing():
				animated_sprite.play("att_dash")
			
			att_dash_t += delta
			if att_dash_t >= 1.2 and prepare_dash:
				att_dash_t = 0.0
				prepare_dash = false
				audio_non_hit.play()
				
			if not prepare_dash and not decelerate:
				velocity += dash_direction * delta * dash_speed * 2
				spawn_after_image(delta)
			
			if velocity.length() > dash_speed*1.3 and not decelerate:
				velocity = velocity.normalized() * dash_speed * 1.3

			if global_position.distance_to(target_position)<10 and not decelerate:
				decelerate = true

			if decelerate:
				velocity *= 0.95
				if velocity.length() < 10:
					change_state(State.IDLE)
				



	move_and_slide()

	

func change_face_direction_and_position():
	target_position = player.global_position
	if current_state == State.ATT_DASH:
		if sign(scale.x) == sign(origin_scale_x):
			target_position.x += 30 
			target_position.y -=7
		else:
			target_position.x -= 30 
			target_position.y +=7
	dash_direction = (target_position - global_position).normalized()
	dash_vec = (target_position - global_position)


	if sign(dash_direction.x) != sign(sign_scale_x):
		scale.x = -scale.x
		sign_scale_x = -sign_scale_x

	# print("scale.x",scale.x)
	# if target_position.y < limit_top :
	# 	target_position.y = limit_top
	
	




func change_state(new_state: State) -> void:
	current_state = new_state
	state_timer = 0.0
	attack_collision.disabled = true
	attack_collision_att_dash.disabled = true
	decelerate=false
	

	match new_state:
		State.IDLE:
			idx += 1
		State.ATTACKING:
			velocity = Vector2.ZERO
			if randi() % 2 == 0:
				animated_sprite.play("attacking")
			else:
				animated_sprite.play("attacking2")
			timer.start()
			timer_audio.start()
		State.DASH:
			change_face_direction_and_position()
			velocity = dash_direction * dash_speed
		State.ATT_DASH:
			change_face_direction_and_position()

			velocity = - dash_direction * dash_speed * 0.2
			attack_collision_att_dash.disabled = false
			animated_sprite.play("att_dash")
			prepare_dash = true 
