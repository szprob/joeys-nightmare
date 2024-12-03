extends AnimatableBody2D

@export var rotation_angular_velocity: float = 5.0
@export var clockwise: bool = true

func _physics_process(delta):
    var rotation_direction = 1 if clockwise else -1
    rotation += rotation_angular_velocity * delta * rotation_direction

