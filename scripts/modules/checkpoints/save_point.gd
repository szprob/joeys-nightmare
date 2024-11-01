extends Area2D

var player_inside = false

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):  # 确保只对玩家触发
		player_inside = true
		# 保存位置
		$AnimatedSprite2D.frame = 1
		print("Player entered save point")
		GameManager.game_state['current_respawn_point'] = position
		GameManager.game_state['respawn_enable'] = true
		GameManager.save_game_state()
		

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_inside = false
		$AnimatedSprite2D.frame = 0
		print("Player exited")
