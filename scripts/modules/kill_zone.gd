extends Area2D

var particles
var player 

@onready var timer: Timer = $Timer


func _ready():
	# Engine.time_scale = 1
	# 获取玩家节点
	player = get_tree().get_first_node_in_group("player")
	player.set_can_move(true)


func _on_body_entered(body: Node2D) -> void:
	if not GameManager.game_state_cache['can_detect_kill_zone']:
		return
	
	if not body.is_in_group("player"):
		return 

	player.set_can_move(false, 'death')

	GameManager.game_state_cache['can_detect_kill_zone'] = false
	GameManager.game_state['number_deaths'] += 1
	print('number_deaths : ', GameManager.game_state['number_deaths'])
	# Engine.time_scale = 0.5
	# if body.has_method("respawn"):
	# 	body.respawn()
	
	create_collision_effect(body.global_position)
	
	

func _on_timer_timeout() -> void:
	# Engine.time_scale = 1
	GameManager.game_state_cache['can_detect_kill_zone'] = true
	player.set_can_move(true)
	# var root_node = get_tree().get_root()
	var root_node = get_tree().current_scene
	cleanup_dynamic_nodes()
	get_tree().change_scene_to_file(root_node.scene_file_path)


func cleanup_dynamic_nodes() -> void:
	# 假设你给所有动态添加的节点都加了一个组名
	var dynamic_nodes = get_tree().get_nodes_in_group("dynamic")
	for node in dynamic_nodes:
		node.queue_free()



func create_collision_effect(pos: Vector2):
	particles = CPUParticles2D.new()
	add_child(particles)
	particles.global_position = pos
	
	# 基础设置
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0  # 增加爆发性
	particles.amount = 100
	particles.lifetime = 1  # 缩短生命周期
	particles.direction = Vector2.UP
	particles.spread = 180  # 减小扩散角度，主要向上飞溅
	particles.initial_velocity_min = 150
	particles.initial_velocity_max = 250
	particles.scale_amount_min = 2
	particles.scale_amount_max = 4
	# 血液颜色渐变
	var color_ramp = Gradient.new()
	color_ramp.add_point(0.0, Color(0.8, 0.0, 0.0, 1.0))  # 鲜红色
	color_ramp.add_point(0.6, Color(0.6, 0.0, 0.0, 0.8))  # 暗红色
	color_ramp.add_point(1.0, Color(0.4, 0.0, 0.0, 0))    # 褐红色渐隐
	particles.color_ramp = color_ramp
	
	# 增强重力效果
	particles.gravity = Vector2(0, 980)  # 增加重力
	particles.damping_min = 0.5  # 增加阻尼
	particles.damping_max = 1.0
	
	# 角度设置
	particles.angle_min = -45
	particles.angle_max = 45
	
	# 设置粒子自动销毁
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()
	timer.start()
	
