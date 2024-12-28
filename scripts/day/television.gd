extends AnimatedSprite2D

@onready var kelly: Sprite2D = $Kelly

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.game_state['is_kelly_show']:
		kelly.show()
		stop()
		frame = 12
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_kelly() -> void:
	kelly.show()
