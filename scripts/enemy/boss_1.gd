extends Area2D

var player
var areas: Array[Area2D] = []
var current_area_index = 0
var state = "idle"
var idle_timer = 0 
var aim_timer = 0
var prepare_shoot_timer = 0
var shoot_timer = 0
var stun_timer = 0
var dash_timer = 0
var target_position = Vector2.ZERO
var next_position = Vector2.ZERO
var line_max_distance = 1000  # 射线最大距离
var line_collision_mask = 1  # 根据你的碰撞层设置
var line_target_point = Vector2.ZERO
var is_line_flashing = false
var flash_time = 0.0
var do_detect=true # 是否检测碰撞
var camera: Camera2D
var is_shaking = false
var velocity = Vector2.ZERO  # 声明 velocity 变量

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var line_2d: Line2D = $Line2D
@onready var line_2d2: Line2D = $Line2D
@onready var kill_zone: Area2D = $kill_zone
@onready var kill_collision: CollisionShape2D = $kill_zone/CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var idle_time = 1 
@export var aim_time: float = 2.0
@export var prepare_shoot_time: float = 1.0
@export var shoot_time: float = 0.5
@export var stun_time: float = 2.0
@export var dash_time: float = 1.5
@export var invincible_duration: float = 5.0
@export var dash_speed: float = 400.0




func _ready():
	player = get_tree().get_first_node_in_group("player")
	camera = get_tree().get_first_node_in_group("camera")  # 获取相机引用
	for child in get_children():
		if child is Area2D:
			areas.append(child)
	line_2d.visible = false
	line_2d2.visible = false
	body_entered.connect(on_body_entered)
	
	change_state("idle")

func _physics_process(delta):
	if player:
		match state:
			"idle":
				handle_idle_state(delta)
			"aim":
				handle_aim_state(delta)
			"prepare_shoot":
				handle_prepare_shoot_state(delta)
			"shoot":
				handle_shoot_state(delta)
			"dash":
				handle_dash_state(delta)
			"stun":
				handle_stun_state(delta)

func handle_idle_state(delta):
	idle_timer += delta
	if idle_timer >= idle_time:
		change_state("aim")

func handle_aim_state(delta):
	aim_timer += delta
	line_2d.visible = true
	line_2d.width = 1
	var start_point = global_position
	line_2d.global_position = start_point
	
	# 射线检测
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	query.collision_mask = line_collision_mask
	var result = space_state.intersect_ray(query)
	
	if result:
		line_target_point = result.position
	else:
		line_target_point = player.global_position
	
	line_2d.points = [Vector2.ZERO, line_target_point - start_point]
	
	if aim_timer >= aim_time:
		target_position = player.global_position
		change_state("prepare_shoot")

func handle_prepare_shoot_state(delta):
	prepare_shoot_timer += delta
	line_2d.visible = true
	line_2d.width = 2
	# 闪烁效果
	flash_time += delta * 13  # 控制闪烁速度
	var flash_intensity = abs(sin(flash_time))
	line_2d.default_color = Color(1, 0, 0, flash_intensity)
	line_2d.points = [Vector2.ZERO, line_target_point - global_position]
	
	if prepare_shoot_timer >= prepare_shoot_time:
		change_state("shoot")

func handle_shoot_state(delta):
	shoot_timer += delta
	line_2d2.visible = true
	line_2d2.width = 3
	line_2d2.default_color = Color(1, 0, 0, 1)  # 保持高亮
	
	if shoot_timer >= shoot_time:
		change_state("idle")

func handle_stun_state(delta):
	stun_timer += delta
	if stun_timer >= 2.0:
		current_area_index += 1
		if current_area_index >= areas.size():
			die()
		else:
			next_position = areas[current_area_index].global_position
			change_state("dash")

func handle_dash_state(delta):
	dash_timer += delta
	velocity = (next_position - global_position).normalized() * dash_speed
	global_position += velocity * delta
	
	if dash_timer >= 1.0 or global_position.distance_to(next_position) < 10:
		global_position = next_position
		change_state("idle")


func change_state(new_state):
	state = new_state
	idle_timer = 0 
	aim_timer = 0
	shoot_timer = 0
	stun_timer = 0
	dash_timer = 0
	flash_time = 0
	line_2d.default_color = Color(1, 0, 0, 1)  # 重置线条颜色
	line_2d.visible = false
	line_2d2.visible = false
	do_detect = not (new_state == "stun" or new_state == "dash")
	collision_shape.disabled = (new_state == "stun" or new_state == "dash")
	
	match new_state:
		"idle":
			animated_sprite.play("idle")
		"aim":
			animated_sprite.play("idle")
		"prepare_shoot":
			animated_sprite.play("idle")
		"shoot":
			animated_sprite.play("shoot")
			audio_player.play()
		"dash":
			animated_sprite.play("dash")
		"stun":
			animated_sprite.play("stun")

func die():
	queue_free()  # 或者播放死亡动画后再释放

func update_line_collision():
	var line_length = line_2d2.points[1].length()
	var line_direction = line_2d2.points[1].normalized()
	
	# 创建一个矩形形状
	var shape = RectangleShape2D.new()
	shape.size = Vector2(line_length, 10)  # 10是线的宽度，可以调整
	
	# 更新碰撞形状
	kill_collision.shape = shape
	
	# 设置位置和旋转
	kill_collision.position = line_2d2.points[1] / 2
	kill_collision.rotation = line_direction.angle()
	
	# 根据状态启用/禁用碰撞
	kill_collision.disabled = not (state == "shoot")


# 定义 on_body_entered 函数
func on_body_entered(body):
	if body.is_in_group("player") and do_detect:
		change_state("stun")
		# 添加振动效果
		GameManager.camera_shake_requested.emit(15, 0.2)
		# 给玩家一个反向作用力
		if body.has_method("apply_force"):
			var collision_direction = (body.global_position - global_position).normalized()
			body.apply_force(collision_direction * 1000)
