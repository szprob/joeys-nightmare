extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.get_day_phase() != 8:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.has_item('钥匙2'):
		queue_free()
