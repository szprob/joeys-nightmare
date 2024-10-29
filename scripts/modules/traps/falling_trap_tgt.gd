extends Area2D

@export var speed: float = Consts.FALLING_TRAP_SPEED  # 可配置的速度
@export var reset_delay : float = 1 
@export var do_reset :bool = false

var is_flying_forward: bool = false
var is_flying_backward: bool = false
var fly_direction: Vector2 = Vector2.ZERO
var init_position: Vector2 = Vector2.ZERO
var final_position : Vector2 = Vector2.ZERO

@onready var falling_trap: Area2D = $"."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer
@onready var target: Area2D = $target
@onready var target_sprite_2d: Sprite2D = $target/Sprite2D
@onready var timer2: Timer = $Timer2


func _ready() -> void:
	init_position = position
	target_sprite_2d.visible = false
	final_position=target.global_position
	timer2.wait_time = reset_delay


func _physics_process(delta):
	if is_flying_forward:
		position += fly_direction * speed * delta
		if position.distance_to(final_position) < speed * delta:  # 10.0 is a small threshold to consider it reached
			position = final_position
			if do_reset:
				is_flying_forward=false
				timer2.start() 
			else:
				queue_free()
	if is_flying_backward:
		position += fly_direction * speed * delta
		if position.distance_to(init_position) < speed * delta:  # 10.0 is a small threshold to consider it reached
			position = init_position
			queue_free()
		
		

func _on_timer_timeout() -> void:
	is_flying_forward = true
	fly_direction = (final_position  - position).normalized()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D : 
		timer.start()

func _on_timer_2_timeout() -> void:
	is_flying_backward = true
	fly_direction = (init_position  - position).normalized()
