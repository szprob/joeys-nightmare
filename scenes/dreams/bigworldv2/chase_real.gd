extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.game_state_cache['should_die'] = true
	GameManager.play_bgm('chase')