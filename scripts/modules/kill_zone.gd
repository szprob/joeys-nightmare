extends Area2D
@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	print("die!!")
	Engine.time_scale = 0.5
	# if body.has_method("respawn"):
	# 	body.respawn()
	timer.start()
	

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	# var root_node = get_tree().get_root()
	var root_node = get_tree().current_scene
	print('root node', root_node.name)
	
	cleanup_dynamic_nodes()
	get_tree().change_scene_to_file(root_node.scene_file_path)


func cleanup_dynamic_nodes() -> void:
	# 假设你给所有动态添加的节点都加了一个组名
	var dynamic_nodes = get_tree().get_nodes_in_group("dynamic")
	for node in dynamic_nodes:
		node.queue_free()
