class_name ShootController
extends Node

var parent: CharacterBody2D
var can_shoot: bool = true
var facing_direction: int = 1
var bullet_scene: PackedScene
var cooldown: float

func _init(parent_node: CharacterBody2D, bullet: PackedScene, shoot_cooldown: float):
    parent = parent_node
    bullet_scene = bullet
    cooldown = shoot_cooldown

func shoot(input: InputEvent) -> void:
    if not can_shoot:
        return
        
    var shoot_direction = calculate_shoot_direction(input)
    spawn_bullet(shoot_direction)
    
    can_shoot = false
    # 需要在parent中设置计时器
    parent.get_node("GunCooldown").start()

func calculate_shoot_direction(input: InputEvent) -> Vector2:
	var shoot_direction = Vector2(facing_direction, 0)
	if not (input.is_action_pressed('up') or input.is_action_pressed('down') or
			input.is_action_pressed('left') or input.is_action_pressed('right')):
		return shoot_direction
		
	shoot_direction = Vector2.ZERO
	if input.is_action_pressed("up"):
		shoot_direction.y = -1
	if input.is_action_pressed("down"):
		shoot_direction.y = 1
	if input.is_action_pressed("left"):
		shoot_direction.x = -1
	if input.is_action_pressed("right"):
		shoot_direction.x = 1
		
	return shoot_direction



func spawn_bullet(shoot_direction: Vector2) -> void:
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(position + Vector2(0, -8), shoot_direction)