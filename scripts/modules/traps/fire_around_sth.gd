extends Area2D

var distance_to_around_sth
var around_position 
var current_angle

@export var around_sth: Node2D
@export var rotation_angular_velocity: float = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await around_sth.ready
	around_position = around_sth.global_position
	distance_to_around_sth = global_position.distance_to(around_sth.global_position)
	current_angle = global_position.angle_to_point(around_position)


func _physics_process(delta):
	if !around_sth:
		return
	around_position = around_sth.global_position
	if !distance_to_around_sth:
		distance_to_around_sth = global_position.distance_to(around_position)

	if !current_angle:
		current_angle = global_position.angle_to_point(around_position)
		return 
	current_angle += rotation_angular_velocity * delta

	# 根据新角度和距离计算新的位置
	global_position = around_position + Vector2(
		cos(current_angle) * distance_to_around_sth,
		sin(current_angle) * distance_to_around_sth
	)
	
	# 让fire始终朝向around_sth
	#var direction_to_around = (global_position - around_position).normalized()
	#rotation = direction_to_around.angle() 
	
