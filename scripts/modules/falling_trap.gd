extends Area2D

var is_falling: bool = false
var fall_timer: Timer

@onready var falling_trap: Area2D = $"."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer

func _on_body_entered(body):
	print("body in falling_trap")
	if body is CharacterBody2D : 
		timer.start()
	else:
		print('1')

func _process(delta):
	if is_falling:
		position.y += Consts.FALLING_TRAP_SPEED * delta
		if position.y > get_viewport().size.y+200:  # 如果陷阱超出屏幕下方
			queue_free()

func _on_timer_timeout() -> void:
	is_falling = true
