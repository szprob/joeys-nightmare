class_name GravityController
extends Node

var parent: CharacterBody2D

func _init(parent_node: CharacterBody2D):
    parent = parent_node

func apply_gravity(delta: float, velocity: Vector2) -> Vector2:
    if not parent.is_on_terrain():
        var gravity = parent.get_gravity()
        var gravity_dir = gravity.normalized()
        
        velocity += gravity * delta
        
        # 限制下落速度
        var velocity_along_gravity = velocity.project(gravity_dir)
        if velocity_along_gravity.length() > Consts.MAX_FALLING_SPEED:
            velocity_along_gravity = velocity_along_gravity.normalized() * Consts.MAX_FALLING_SPEED
            var velocity_perpendicular = velocity - velocity.project(gravity_dir)
            velocity = velocity_along_gravity + velocity_perpendicular
            
    return velocity