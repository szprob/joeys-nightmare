extends Sprite2D

@onready var animation_player: AnimationPlayer = $Key1Animation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("key1 detect day_phase: ", GameManager.get_day_phase())
	if GameManager.get_day_phase() != 5:
		queue_free()
	animation_player.play("blink")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.get_day_phase() == 6:
		queue_free()
