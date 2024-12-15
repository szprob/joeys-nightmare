extends Area2D

var sound_effects = [
	"res://assets/sounds/day/piano-g-6200.mp3",
	"res://assets/sounds/day/fa-78409.mp3",
	"res://assets/sounds/day/la-80237.mp3",
	"res://assets/sounds/day/mi-80239.mp3",
	"res://assets/sounds/day/re-78500.mp3",
	"res://assets/sounds/day/si-80238.mp3",
	"res://assets/sounds/day/sol-101774.mp3",
	"res://assets/sounds/day/do-80236.mp3"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func action() -> void:
	var index = int(randf_range(0, sound_effects.size()))
	SoundPlayer.play_sound(sound_effects[index])
