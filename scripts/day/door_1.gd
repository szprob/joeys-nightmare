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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.is_room3_door_open() and not is_door_open:
		SoundPlayer.play_sound("res://assets/sounds/day/open-door-sound-247415.mp3")
		frame = 0
		play("open")
		is_door_open = true
