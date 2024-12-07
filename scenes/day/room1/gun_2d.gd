extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("ready for gun, day phase: ", GameManager.get_day_phase())
	if GameManager.get_day_phase() >= 4:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.get_day_phase() == 4:
		assert(not GameManager.get_items().has(name))
		GameManager.add_item(name)
		queue_free()
