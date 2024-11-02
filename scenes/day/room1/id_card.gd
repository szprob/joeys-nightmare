extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Outline.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.get_day_phase() == 1:
		$Outline.show()
	if GameManager.get_day_phase() == 2:
		assert(not GameManager.get_items().has(name))
		GameManager.add_item(name)
		queue_free()
