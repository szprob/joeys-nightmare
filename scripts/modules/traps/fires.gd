extends AnimatableBody2D

@export var rotation_angular_velocity: float = 5.0
@export var clockwise: bool = true
@export var initial_rotation: float = 0.0

func _ready():
	rotation = initial_rotation

func _physics_process(delta):
	var rotation_direction = 1 if clockwise else -1
	rotation += rotation_angular_velocity * delta * rotation_direction
	
