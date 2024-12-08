extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var water_phase = GameManager.get_tub_water_phase()
	process_animation(water_phase)
	
func process_animation(water_phase: int) -> void:
	match water_phase:
		1:
			play("watering")
		2:
			play("water_idle")
		_:
			return


func _on_animation_finished() -> void:
	if animation == 'watering':
		GameManager.inc_tub_water_phase()
