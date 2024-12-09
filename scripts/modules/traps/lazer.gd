extends Node2D

var lazer_particles_scene = preload("res://scenes/modules/ui/lazer_particles.tscn")
var current_particles: GPUParticles2D = null
var end_particles: GPUParticles2D = null
var player

@onready var line2d: Line2D = $Line2D
@onready var kill_zone_shape: CollisionShape2D = $kill_zone/CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var area1: Area2D = null
@export var area2: Area2D = null
@export var is_blink: bool = false
@export var blink_time: float = 0.9


# 激光动画参数
var time: float = 0
var amplitude: float = 2.0
var frequency: float = 5.0
var can_visible: bool = true
var blink_timer: float = 0

func _ready() -> void:
	current_particles = lazer_particles_scene.instantiate()
	current_particles.emitting = false
	add_child(current_particles)

	end_particles = lazer_particles_scene.instantiate()
	end_particles.emitting = false
	add_child(end_particles)

	kill_zone_shape.shape = RectangleShape2D.new()
	draw_kill_zone_shape()


	# 调整激光宽度
	line2d.width = 1
	# 设置更加鲜艳的红色,增加绿色和蓝色通道的值使其更加明亮
	line2d.default_color = Color(1.0, 0.0, 0.0, 1.0)

	# 增强发光效果
	#var canvas_item_material = CanvasItemMaterial.new()
	#canvas_item_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	#line2d.material = canvas_item_material
	
	# 添加额外的发光效果
	#line2d.set_meta("glow_enabled", true)
	player = get_tree().get_first_node_in_group("player")

	# # 设置音频为循环播放
	# audio_player.stream.loop = true
	# audio_player.play()


func draw_kill_zone_shape() -> void:
	# 获取两端点的位置
	var start_pos = area1.global_position
	var end_pos = area2.global_position
	
	# 计算矩形的中心点和尺寸
	var center = (start_pos + end_pos) / 2
	var length = start_pos.distance_to(end_pos)
	var angle = (end_pos - start_pos).angle()
	
	# 设置碰撞形状
	kill_zone_shape.position = to_local(center)
	kill_zone_shape.rotation = angle
	(kill_zone_shape.shape as RectangleShape2D).size = Vector2(length, 2)

func _process(delta: float) -> void:

	time += delta
	if is_blink:
		blink_timer += delta
		if blink_timer >= blink_time:
			blink_timer = 0
			can_visible = !can_visible
	draw_kill_zone_shape()
	if !can_visible:
		line2d.default_color.a = 0.2
		kill_zone_shape.disabled = true
	else:
		line2d.default_color.a = 1.0
		kill_zone_shape.disabled = false

	# 获取两端点的位置
	var start_pos = area1.global_position
	var end_pos = area2.global_position
	
	# 更新激光线的位置
	line2d.clear_points()
	# 添加轻微随机抖动
	var points_count = 10
	for i in range(points_count + 1):
		var t = float(i) / points_count
		var pos = start_pos.lerp(end_pos, t)
		# 添加小范围随机偏移
		pos += Vector2(
			randf_range(-0.5, 0.5),
			randf_range(-0.5, 0.5)
		)
		line2d.add_point(to_local(pos))
	
	
	
	# 更新粒子效果位置
	current_particles.global_position = start_pos
	current_particles.emitting = true
	
	end_particles.global_position = end_pos
	end_particles.emitting = true

	# 获取玩家节点
	# if player:
	# 	# 计算与玩家的距离
	# 	var distance = global_position.distance_to(player.global_position)
		
		# # 根据距离调整音量
		# if distance < 50:
		# 	audio_player.volume_db = -10.0
		# elif distance < 300:
		# 	# 在200-400范围内线性插值音量，从-5db到-80db(静音)
		# 	var t = (distance - 50) / 250  # 归一化到0-1范围
		# 	var volume_db = lerp(-10.0, -80.0, t)
		# 	audio_player.volume_db = volume_db
		# else:
		# 	audio_player.volume_db = -80.0
