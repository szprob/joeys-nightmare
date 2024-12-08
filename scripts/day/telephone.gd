extends Sprite2D

@onready var bubble: Sprite2D = $Bubble
@onready var animation: AnimationPlayer = $Bubble/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bubble.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.is_room2_entered() and GameManager.get_day_phase() < 7:
		bubble.show()
		animation.play("jump")
	else:
		animation.stop()
		bubble.hide()
