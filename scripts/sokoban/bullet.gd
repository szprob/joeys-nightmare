extends Area2D

@export var speed = 250
var direction = Vector2(0, 0) # 默认方向


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func start(pos, shoot_direction):
	print(shoot_direction)
	position = pos
	
	shoot_direction = shoot_direction.normalized()
	direction = shoot_direction



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	position += speed * direction * delta


#func _on_area_entered(area: Area2D) -> void:
	#if area is TileMapLayer:
		#print('hit tilemap, add a gravity area')
		
		


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	# TODO: hit tilemap and put a gravity
	if body is TileMapLayer:
		print('hit tilemap, add gravity')
		# 实例化gravity节点
		var gravity_scene = preload("res://scenes/sokoban/gravity_1.tscn")
		var gravity_instance = gravity_scene.instantiate()

		# 设置gravity节点的位置为当前子弹的位置
		gravity_instance.position = position + Vector2(0, gravity_instance.get_node("CollisionShape2D").shape.get_size().y/2)
		
		get_tree().root.add_child(gravity_instance)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
