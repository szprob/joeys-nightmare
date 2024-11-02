extends Sprite2D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.get_day_phase() >= 4:
		queue_free()
