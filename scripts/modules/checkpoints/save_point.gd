extends Area2D

var player_inside = false

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):  # 确保只对玩家触发
		player_inside = true
		# 保存位置
		GameManager.game_state['current_respawn_point'] = position
		GameManager.save_game_state()
		

func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		player_inside = false
		print("Player exited")
