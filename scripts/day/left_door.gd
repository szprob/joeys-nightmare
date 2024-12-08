extends AnimatedSprite2D

@onready var body: StaticBody2D = $StaticBody2D
@onready var dialogue_action: Area2D = $Actionable
var animation_played = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stop()
	animation = "open"
	if GameManager.is_left_door_opened():
		animation_played = true
		frame = 1
		body.queue_free()
		dialogue_action.queue_free()
	else:
		animation_played = false
		frame = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.is_left_door_opened() and not animation_played:
		SoundPlayer.play_sound("res://assets/sounds/interface/door.wav")
		frame = 1
		animation_played = true
		# body.rotate(-PI / 2)
		body.queue_free()
		dialogue_action.queue_free()
