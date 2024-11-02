extends Area2D
var player_inside = false  # 用于跟踪玩家是否在存档点内

func _process(delta):
	if Input.is_action_just_pressed("select") and player_inside:
		get_tree().change_scene_to_file("res://scenes/day/game/game.tscn")

func _on_body_entered(body: CharacterBody2D) -> void:
	if body is CharacterBody2D:
		player_inside = true
		print('Player in!')
	
func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		player_inside = false
		print("Player exited")
