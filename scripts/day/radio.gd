extends Sprite2D

@onready var actionable: Area2D = $Actionable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	actionable.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.get_day_phase() == 2:
		actionable.show()
