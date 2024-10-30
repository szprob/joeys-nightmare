extends AnimatableBody2D

@export var speed: float = 30 

var is_moving: bool = false
var move_direction: Vector2 = Vector2.ZERO
var final_position : Vector2 = Vector2.ZERO
var init_position : Vector2 = Vector2.ZERO

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var target: Area2D = $target
@onready var detection: Area2D = $detection



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.visible=false
	final_position = target.global_position
	init_position = position
	move_direction = (target.global_position - position).normalized()
	
	# 建立信号连接
	detection.body_entered.connect(_on_detection_body_entered)



func _physics_process(delta):
	if is_moving:
		position += move_direction * speed * delta  
		if position.distance_to(final_position) < 5: 
			position = final_position
			is_moving = false


func _on_detection_body_entered(body: Node2D) -> void: 
	if body is CharacterBody2D:
		is_moving = true
		sprite_2d.visible=true
