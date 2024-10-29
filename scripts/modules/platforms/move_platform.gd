extends AnimatableBody2D

var is_moving: bool = false
var move_direction: Vector2 = Vector2.ZERO
var distance  = 0 
var final_position : Vector2 = Vector2.ZERO
var still_there = false
var do_detect = true #是否做检测

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer
@onready var target: Area2D = $target

func _on_ready() -> void:
	final_position=target.global_position
	move_direction = (target.global_position - position).normalized()
	distance = final_position.distance_to(position)
		
func _on_detection_body_entered(body: Node2D) -> void:
	if do_detect and body is CharacterBody2D:
		do_detect=false
		still_there = true
		timer.start()

func _physics_process(delta):
	if is_moving:
		position += move_direction * Consts.MOVE_PLATFORM_SPEED * delta
		if position.distance_to(final_position) < Consts.MOVE_PLATFORM_SPEED * delta:
			position = final_position
			is_moving = false

func _on_timer_timeout() -> void:
	if still_there:
		is_moving = true


func _on_detection_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		still_there = false
