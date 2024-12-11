extends Area2D

@export var light_sprite: Sprite2D
@export var index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	light_sprite.visible = GameManager.get_light_visble(index)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func action() -> void:
	SoundPlayer.play_sound("res://assets/sounds/day/light-switch-81967.mp3")
	if light_sprite.visible:
		light_sprite.hide()
	else:
		light_sprite.show()
	GameManager.set_light_visble(light_sprite.visible, index)
