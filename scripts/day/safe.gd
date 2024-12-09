extends Sprite2D

var is_open: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	decide_frame()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_open and GameManager.is_all_light_off():
		SoundPlayer.play_sound("res://assets/sounds/day/lock-sound-effect-247455.mp3")
		GameManager.start_dialogue()
		GameManager.show_dialogue(load("res://scenes/day/dialogues/room2.dialogue"), "safe_open")
	decide_frame()

func decide_frame() -> void:
	is_open = GameManager.is_all_light_off()
	if GameManager.is_all_light_off():
		if GameManager.has_item("钩爪"):
			frame = 1
		else:
			frame = 0
	else:
		frame = 2
