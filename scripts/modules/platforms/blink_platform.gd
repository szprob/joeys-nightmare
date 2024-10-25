extends AnimatableBody2D

var is_visible = true

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer #启动时间
@onready var timer_2: Timer = $Timer2 #闪烁间隔
@onready var sprite_2d: Sprite2D = $Sprite2D

func _on_ready() -> void:
	timer.start()
		

func _on_timer_timeout() -> void:
	timer_2.start()  # Start the blinking timer


func _on_timer_2_timeout() -> void:
	is_visible = !is_visible
	sprite_2d.visible = is_visible
	collision_shape_2d.disabled = !is_visible
