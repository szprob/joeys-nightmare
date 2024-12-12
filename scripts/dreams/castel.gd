extends Node2D

func _ready() -> void:
	if not GameManager.game_state_cache['bmg_set']:
		GameManager.setup_bgm_player()
	GameManager.play_bgm('church')
