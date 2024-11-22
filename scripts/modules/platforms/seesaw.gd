extends Node2D

@export var rotation_speed: float = 2.0
@export var max_rotation: float = 30.0

var current_rotation: float = 0.0
var left_weight: float = 0.0
var right_weight: float = 0.0

func _ready() -> void:
	current_rotation = rotation_degrees

func _physics_process(delta: float) -> void:
	var target_rotation = sign(right_weight - left_weight) * max_rotation
	
	current_rotation = lerp(current_rotation, target_rotation, rotation_speed * delta)
	rotation_degrees = current_rotation

func _on_left_side_body_entered(body: CharacterBody2D) -> void:
	if body.has_meta("mass"):
		left_weight += body.mass

func _on_left_side_body_exited(body: CharacterBody2D) -> void:
	if body.has_meta("mass"):
		left_weight -= body.mass

func _on_right_side_body_entered(body: CharacterBody2D) -> void:
	if body.has_meta("mass"):
		right_weight += body.mass

func _on_right_side_body_exited(body: CharacterBody2D) -> void:
	if body.has_meta("mass"):
		right_weight -= body.mass





