extends Node2D

@onready var sound_player: AudioStreamPlayer2D = $sound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func play_sound(sound_path: String) -> void:
	if ResourceLoader.exists(sound_path):
		sound_player.stream = load(sound_path)
		sound_player.play()
