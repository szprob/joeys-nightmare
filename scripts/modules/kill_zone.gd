extends Area2D

var death_particles_scene = preload("res://scenes/modules/ui/death_particles.tscn")
var current_particles: GPUParticles2D = null
var player 
# var camera 

@onready var timer: Timer = $Timer


func _ready():
	# Engine.time_scale = 1
	# 获取玩家节点
	await get_tree().create_timer(0.1).timeout
	player = get_tree().get_first_node_in_group("player")
	player.set_can_move(true)
	# camera = get_tree().get_first_node_in_group("camera") 
	current_particles = death_particles_scene.instantiate()
	current_particles.emitting = false
	add_child(current_particles)

func _on_body_entered(body: Node2D) -> void:
	if not GameManager.game_state_cache['can_detect_kill_zone']:
		return
	
	if not body.is_in_group("player"):
		return 
	
	GameManager.die_requested.emit()
	GameManager.game_state_cache['can_detect_kill_zone'] = false
	GameManager.game_state['number_deaths'] += 1

	player.set_can_move(false, 'death')
	GameManager.camera_shake_requested.emit(5, 0.2)

	
	
	print('number_deaths : ', GameManager.game_state['number_deaths'])
	# Engine.time_scale = 0.5
	# if body.has_method("respawn"):
	# 	body.respawn()
	
	create_collision_effect(body.global_position)
	timer.start()
	
	

func _on_timer_timeout() -> void:
	# Engine.time_scale = 1
	GameManager.game_state_cache['can_detect_kill_zone'] = true
	player.set_can_move(true)
	# var root_node = get_tree().get_root()
	var root_node = get_tree().current_scene
	cleanup_dynamic_nodes()
	if GameManager.game_state_cache['should_die']:
		get_tree().change_scene_to_file(root_node.scene_file_path)


func cleanup_dynamic_nodes() -> void:
	# 假设你给所有动态添加的节点都加了一个组名
	var dynamic_nodes = get_tree().get_nodes_in_group("dynamic")
	for node in dynamic_nodes:
		node.queue_free()



func create_collision_effect(pos: Vector2):
	if current_particles:
		current_particles.global_position = pos
		current_particles.restart()
		current_particles.emitting = true
