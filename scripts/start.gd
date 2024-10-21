extends Node2D


@onready var game_manager: Node = %game_manager


func _on_play_pressed() -> void:
	print(GameManager.game_state)
	GameManager.load_game_state()
	get_tree().change_scene_to_file("res://scenes/dreams/level1/game.tscn")

func _on_load_pressed() -> void:
	GameManager.load_game_state()
	

func _on_quit_pressed() -> void:
	get_tree().quit()
