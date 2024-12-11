extends Control

@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func play_sfx():
	if sfx_player:
		sfx_player.play()

func _process(delta):
	if Input.is_action_just_pressed("esc"):
		play_sfx()
		get_tree().change_scene_to_file("res://scenes/main/start.tscn")