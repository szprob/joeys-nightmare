extends Area2D

#@export door
@export var door: NodePath
func _ready() -> void:
	# 使用 Callable 连接信号
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
func _on_body_entered(body):
	print(body)
	if body is CharacterBody2D:
		print('CharacterBody2D entered, open the door')
		$AnimatedSprite2D.frame = 1
		if door:
			get_node(door).open()
		
func _on_body_exited(body):
	if body is CharacterBody2D:
		print('CharacterBody2D exited, close the door')
		$AnimatedSprite2D.frame =0
		if door:
			get_node(door).close()
