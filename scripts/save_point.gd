extends Area2D

@onready var game_manager: Node = %game_manager
var player_inside = false  # 用于跟踪玩家是否在存档点内

func _on_body_entered(body: CharacterBody2D) -> void:
	print(position)
	print('saved!')
	if body is CharacterBody2D:
		player_inside = true
		game_manager.game_state['current_respawn_point']  = position
		game_manager.save_game_state()
	
func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		player_inside = false
		print("Player exited")
