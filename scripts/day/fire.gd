extends AnimatedSprite2D

@onready var fire_light: Sprite2D = $FireLight

var extincted: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.is_fire_extincted():
		fire_light.hide()
		stop()
		animation = "extinct"
		frame = 1
	else:
		play("flame")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if extincted:
		return
	if GameManager.is_fire_extincted():
		play("extinct")


func _on_animation_finished() -> void:
	if animation != 'extinct':
		return
	stop()
	fire_light.hide()
	frame = 1
	extincted = true
