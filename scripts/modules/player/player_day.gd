extends CharacterBody2D

var move_direction: Vector2 = Vector2.ZERO
var face_direction: Vector2 = Vector2.ZERO
var is_moving = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func handle_direction():
	move_direction.x = Input.get_axis("left", "right")
	if move_direction.x != 0 :
		face_direction.y = 0
		face_direction.x = move_direction.x
	move_direction.y = Input.get_axis("up", "down")
	if move_direction.y != 0 :
		face_direction.x = 0
		face_direction.y = move_direction.y

func handle_move()-> void:
	if move_direction.x:
		velocity.x = move_direction.x * Consts.SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, Consts.SPEED)
	
	if move_direction.y:
		velocity.y = move_direction.y * Consts.SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, Consts.SPEED)
		
	if move_direction.x !=0 or move_direction.y !=0:
		is_moving=true 
	else:
		is_moving=false
		
	move_and_slide()
	

func handle_animation():
	if is_moving:
		if move_direction.x > 0 :
			animated_sprite_2d.play('run_right')
		elif  move_direction.x < 0:
			animated_sprite_2d.play('run_left') 
		elif move_direction.y < 0:
			animated_sprite_2d.play('run_back')
		else :
			animated_sprite_2d.play('run_front')
	else:
		if face_direction.x > 0 :
			animated_sprite_2d.play('idle_right')
		elif  face_direction.x < 0:
			animated_sprite_2d.play('idle_left') 
		elif face_direction.y < 0:
			animated_sprite_2d.play('idle_back')
		else :
			animated_sprite_2d.play('idle_front')


func _physics_process(delta: float) -> void:
	handle_direction()
	handle_move()
	handle_animation()
		
	
