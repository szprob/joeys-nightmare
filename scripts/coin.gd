extends Area2D

@onready var game_manager: Node = %game_manager

func _on_body_entered(body: Node2D) -> void:
	game_manager.add_point()
	queue_free()
