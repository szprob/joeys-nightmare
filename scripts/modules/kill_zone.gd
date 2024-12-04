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



# 添加新的碰撞效果函数
func create_collision_effect(pos: Vector2):
	# 创建一个 CPUParticles2D 节点来显示碰撞效果
	particles = CPUParticles2D.new()
	add_child(particles)
	particles.global_position = pos
	
	# 设置粒子效果参数
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 50
	particles.lifetime = 1.0
	particles.direction = Vector2.UP
	particles.spread = 180
	particles.initial_velocity_min = 200
	particles.initial_velocity_max = 400
	particles.scale_amount_min = 5
	particles.scale_amount_max = 8
	particles.color = Color(1, 0.2, 0, 1)  # 更鲜艳的橙色
	
	# 设置粒子自动销毁
	await get_tree().create_timer(particles.lifetime).timeout
	particles.queue_free()
	timer.start()