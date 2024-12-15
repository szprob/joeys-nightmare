extends Sprite2D

@onready var body: StaticBody2D = $StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.get_day_phase() == 10:
		body.collision_layer = 10
		hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
