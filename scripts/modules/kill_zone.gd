extends Area2D

var death_particles_scene = preload("res://scenes/modules/ui/death_particles.tscn")
var current_particles: GPUParticles2D = null
var player
# var camera 

@onready var timer: Timer = $Timer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var transition_scene: String = "res://scenes/modules/checkpoints/transition.tscn" # 添加过渡场景路径


func _ready():
	# Engine.time_scale = 1
	# 获取玩家节点
	await get_tree().create_timer(0.1).timeout
	player = get_tree().get_first_node_in_group("player")
	# player.set_can_move(true)
	# camera = get_tree().get_first_node_in_group("camera") 
	current_particles = death_particles_scene.instantiate()
	current_particles.emitting = false
	add_child(current_particles)

func _on_body_entered(body: Node2D) -> void:
	if not GameManager.game_state_cache['can_detect_kill_zone']:
		return
	
	if not body.is_in_group("player"):
		return
	audio_player.play()
	GameManager.die_requested.emit()
	GameManager.game_state_cache['can_detect_kill_zone'] = false
	GameManager.game_state['number_deaths'] += 1
	if player:
		player.set_can_move(false, 'death')
	GameManager.camera_shake_requested.emit(5, 0.2)

	
	print('number_deaths : ', GameManager.game_state['number_deaths'])
	# Engine.time_scale = 0.5
	# if body.has_method("respawn"):
	# 	body.respawn()
	
	create_collision_effect(body.global_position)
	timer.start()
	
# FIXME: add death animation
# func _on_timer_timeout() -> void:
# 	# Reset game state before scene change
# 	GameManager.game_state_cache['can_detect_kill_zone'] = true
	
# 	if is_instance_valid(player):
# 		player.set_can_move(true)
	
# 	var root_node = get_tree().current_scene
# 	var next_scene = root_node.scene_file_path if GameManager.game_state_cache['should_die'] else transition_scene
	
# 	# Scene loading logic
# 	var loader = ResourceLoader.load_threaded_request(next_scene)
	
# 	# Wait for scene loading
# 	while ResourceLoader.load_threaded_get_status(next_scene) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
# 		await get_tree().create_timer(0.1).timeout
	
# 	var scene = ResourceLoader.load_threaded_get(next_scene)
# 	if scene:
# 		GameManager.game_state_cache['can_detect_kill_zone'] = true
# 		get_tree().change_scene_to_packed(scene)


func _on_timer_timeout() -> void:
	# Engine.time_scale = 1
	GameManager.game_state_cache['can_detect_kill_zone'] = true
	
	# var root_node = get_tree().get_root()
	var root_node = get_tree().current_scene
	cleanup_dynamic_nodes()
	if GameManager.game_state_cache['should_die']:
		get_tree().change_scene_to_file(root_node.scene_file_path)
	else:
		get_tree().change_scene_to_file(transition_scene)


func cleanup_dynamic_nodes() -> void:
	var dynamic_nodes = get_tree().get_nodes_in_group("dynamic")
	for node in dynamic_nodes:
		if node != current_particles: # 避免清理当前使用的粒子系统
			node.queue_free()


func create_collision_effect(pos: Vector2):
	# 检查粒子系统是否有效
	if !is_instance_valid(current_particles):
		current_particles = death_particles_scene.instantiate()
		current_particles.emitting = false
		add_child(current_particles)
	
	if current_particles:
		current_particles.global_position = pos
		current_particles.restart()
		current_particles.emitting = true
