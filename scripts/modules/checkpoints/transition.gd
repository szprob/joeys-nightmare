extends Node2D

var target_scene: String
var teleport_type: String
var next_scene_resource: Resource

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	await ready
	if GameManager.game_state_cache['bmg_set']:
		GameManager.stop_bgm()
	teleport_type = GameManager.game_state['teleport_type']
	target_scene = GameManager.game_state['target_scene']

	if teleport_type == 'day2dream':
		animation_player.play()
	elif teleport_type == 'dream2day':
		animation_player.play_backwards()
	elif teleport_type == 'dream2dream':
		animation_player.play()
	
	# 等待动画播放完成后切换场景
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target_scene)
