extends AnimatedSprite2D

var is_door_open:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation = "open"
	stop()
	if GameManager.is_room3_door_open():
		frame = 5
	else:
		frame = 0
	print("door status: ", frame, ", ", is_door_open, ", ", GameManager.is_room3_door_open())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open_door() -> void:
	SoundPlayer.play_sound("res://assets/sounds/day/open-door-sound-247415.mp3")
	frame = 0
	play("open")

func _on_animation_finished() -> void:
	is_door_open = true
	GameManager.enter_day_scene("res://scenes/day/room3/mac_room.tscn")
