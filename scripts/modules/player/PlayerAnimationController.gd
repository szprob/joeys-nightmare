class_name PlayerAnimationController
extends Node

var sprite: AnimatedSprite2D
var collision_shape: CollisionShape2D

func _init(sprite_node: AnimatedSprite2D, collision_node: CollisionShape2D):
    sprite = sprite_node
    collision_shape = collision_node

func update_animation(is_on_terrain: bool, direction: Vector2) -> void:
    if is_on_terrain:
        if direction.x == 0 and direction.y == 0:
            sprite.play('idle')
        else:
            sprite.play('move')
    else:
        sprite.play('jump')

func flip_sprite(direction: Vector2, gravity: Vector2) -> void:
	# flip palyer sprite based on gravity direction
	var gravity = get_gravity().normalized()
	var angle = gravity.angle() - PI / 2 # 加90度使角色垂直于重力方向
	animated_sprite_2d.rotation = angle
	collision_shape_2d.rotation = angle

	if abs(gravity.y) > abs(gravity.x):
		# 垂直重力情况
		if gravity.y > 0: # 重力向下
			if direction.x > 0:
				animated_sprite_2d.flip_h = false
			elif direction.x < 0:
				animated_sprite_2d.flip_h = true
		else: # 重力向上
			if direction.x > 0:
				animated_sprite_2d.flip_h = true
			elif direction.x < 0:
				animated_sprite_2d.flip_h = false
	else:
		# 水平重力情况保持不变
		if gravity.x > 0: # 重力向右
			if direction.y > 0:
				animated_sprite_2d.flip_h = true
			elif direction.y < 0:
				animated_sprite_2d.flip_h = false
		else: # 重力向左
			if direction.y > 0:
				animated_sprite_2d.flip_h = false
			elif direction.y < 0:
				animated_sprite_2d.flip_h = true