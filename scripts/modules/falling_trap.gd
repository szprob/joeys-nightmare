extends Area2D

var is_flying: bool = false
var fly_direction: Vector2 = Vector2.ZERO
var init_x  = 0 
var init_y = 0 

@onready var falling_trap: Area2D = $"."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer
@onready var target: Area2D = $target
@onready var target_sprite_2d: Sprite2D = $target/Sprite2D

func _on_ready() -> void:
	init_x = position.x 
	init_y = position.y 
	target_sprite_2d.visible = false

func _on_body_entered(body):
	if body is CharacterBody2D : 
		fly_direction = (target.global_position  - position).normalized()
		timer.start()
	else:
		print('1')

func _process(delta):
	if is_flying:
		position += fly_direction * Consts.FALLING_TRAP_SPEED * delta
		if abs(position.y  - init_y) > 4000:
			queue_free()
		elif abs(position.x  - init_x) > 4000 :
			queue_free()
		else:
			pass 

func _on_timer_timeout() -> void:
	is_flying = true
