class_name JumpController
extends Node

var parent: CharacterBody2D
var jump_buffer_timer: float = 0.0
var jump_hold_time: float = 0.0
var is_jumping: bool = false

func _init(parent_node: CharacterBody2D):
    parent = parent_node

func handle_jump(delta: float, velocity: Vector2) -> Vector2:
    if is_jumping and Input.is_action_pressed('jump'):
        jump_hold_time += delta
        if jump_hold_time < Consts.MAX_JUMP_HOLD_TIME:
            var gravity_dir = parent.get_gravity().normalized()
            var velocity_projection = velocity.project(gravity_dir).length()
            if velocity_projection < abs(Consts.MAX_JUMP_VELOCITY):
                var target_velocity = -gravity_dir * abs(Consts.MAX_JUMP_VELOCITY)
                velocity = lerp(velocity, target_velocity, delta)
    else:
        is_jumping = false
        
    return velocity

func start_jump() -> Vector2:
    var gravity_dir = parent.get_gravity().normalized()
    var new_velocity = parent.velocity - gravity_dir * abs(Consts.JUMP_VELOCITY)
    jump_hold_time = 0.0
    is_jumping = true
    return new_velocity