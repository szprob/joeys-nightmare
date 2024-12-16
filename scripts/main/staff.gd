extends Control

@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var label: Label = $Label
@onready var label2: Label = $Label2
@onready var sprite: Sprite2D = $Sprite2D
@onready var title: Sprite2D = $Sprite2D3

@export var scroll_speed = 20.0

var end_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func play_sfx():
	if sfx_player:
		sfx_player.play()

func _physics_process(delta):
	end_time += delta
	if Input.is_action_just_pressed("esc"):
		SoundPlayer.stop_sound()
		play_sfx()
		get_tree().change_scene_to_file("res://scenes/main/start.tscn")
		
	if end_time < 54.5:
		label.global_position.y -= scroll_speed * delta
		sprite.global_position.y -= scroll_speed * delta
		label2.global_position.y -= scroll_speed * delta
		title.global_position.y -= scroll_speed * delta


	if end_time > 64:
		get_tree().change_scene_to_file("res://scenes/main/start.tscn")
		SoundPlayer.stop_sound()
