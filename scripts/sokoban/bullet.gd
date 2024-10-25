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
	if body is TileMapLayer:
		print('hit tilemap, add gravity')
		queue_free()
		
	


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
