extends AnimatableBody2D

var is_visible = true

@onready var timer: Timer = $Timer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D



func _on_detection_body_entered(body: Node2D) -> void:
	if is_visible:
		if body is CharacterBody2D:
			timer.start()


func _on_timer_timeout() -> void:
	is_visible = !is_visible
	sprite_2d.visible = is_visible
	collision_shape_2d.disabled = !is_visible
