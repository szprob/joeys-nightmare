extends Area2D

#@export door
@export var doors: Array[NodePath]

func _ready() -> void:
	# 使用 Callable 连接信号
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
func _on_body_entered(body):
	print(body)
	if body is CharacterBody2D:
		print('CharacterBody2D entered, open the doors')
		$AnimatedSprite2D.frame = 1
		# 遍历所有门并打开
		for door_path in doors:
			if door_path:
				get_node(door_path).open()
		
func _on_body_exited(body):
	if body is CharacterBody2D:
		print('CharacterBody2D exited, close the doors')
		$AnimatedSprite2D.frame = 0
		# 遍历所有门并关闭
		for door_path in doors:
			if door_path:
				get_node(door_path).close()
