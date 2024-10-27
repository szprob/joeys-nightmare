extends CharacterBody2D

var move_direction: Vector2 = Vector2.ZERO
var face_direction: Vector2 = Vector2.ZERO
var is_moving = false
var is_got_gun = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var action_finder: Area2D = $Direction/Finder
@onready var finder_direction: Marker2D = $Direction
	

func handle_direction():
	move_direction.x = Input.get_axis("left", "right")
	if move_direction.x != 0 :
		face_direction.y = 0
		face_direction.x = move_direction.x
		finder_direction.rotation_degrees = -face_direction.x * 90
	move_direction.y = Input.get_axis("up", "down")
	if move_direction.y != 0 :
		face_direction.x = 0
		face_direction.y = move_direction.y
		finder_direction.rotation_degrees = min((-face_direction.y + 1) * 180, 180)

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
	#print("got gun: ", is_got_gun, " phase: ", GameManager.game_state['day_phase'])
	if GameManager.get_day_phase() < 1 and not GameManager.is_chatting():
		GameManager.start_dialogue()
		GameManager.show_dialogue(load("res://scenes/day/dialogues/openning.dialogue"), "title")
		GameManager.set_day_phase(1)
	if GameManager.get_day_phase() > 1 and is_got_gun == false:
		is_got_gun = true
	if not GameManager.is_chatting():
		handle_direction()
		handle_move()
		handle_animation()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		var actionables = action_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()
			return
		#GameManager.start_dialogue()
		#GameManager.show_dialogue(load("res://scenes/day/dialogues/pick_up_gun.dialogue"), "title")


#func _on_area_2d_area_entered(area: Area2D) -> void:
	#print("found player!")
	#if Input.is_action_pressed("shoot"):
		#GameManager.start_dialogue()
		#GameManager.show_dialogue(load("res://scenes/day/dialogues/pick_up_gun.dialogue"), "title")
#
#
#func _on_entrance_area_entered(area: Area2D) -> void:
	#print("found player!")
	#if Input.is_action_pressed("shoot"):
		#GameManager.start_dialogue()
		#GameManager.show_dialogue(load("res://scenes/day/dialogues/entrance_check.dialogue"), "title")
		## TODO enter the dream stage
