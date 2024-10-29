extends AnimatableBody2D

@export var speed: float = 30 

var is_moving: bool = false
var move_direction: Vector2 = Vector2.ZERO
var distance  = 0 
var final_position : Vector2 = Vector2.ZERO
var init_position : Vector2 = Vector2.ZERO

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var target: Area2D = $target
@onready var target_sprite_2d: Sprite2D = $target/Sprite2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_sprite_2d.visible = false
	sprite_2d.visible=false
	final_position = target.global_position
	init_position = position
	move_direction = (target.global_position - position).normalized()


func _physics_process(delta):
	if is_moving:
		position += move_direction * Consts.MOVE_PLATFORM_SPEED * delta
		if position.distance_to(final_position) < speed * delta:
			position = final_position
			is_moving = false


func _on_detection_body_entered(body: Node2D) -> void:
	is_moving = true
	sprite_2d.visible=true
