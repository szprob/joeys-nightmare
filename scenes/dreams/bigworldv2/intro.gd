extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not GameManager.game_state_cache['bmg_set']:
		GameManager.setup_bgm_player()
	GameManager.play_bgm('intro')
