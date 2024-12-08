extends CharacterBody2D

@export var dialog_resource :DialogueResource
@export var dialog_start:String
@export var dialog_finished_phase := 1

var move_direction: Vector2 = Vector2.ZERO
var face_direction: Vector2 = Vector2.ZERO
var is_moving = false
var is_got_gun = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var action_finder: Area2D = $Direction/Finder
@onready var finder_direction: Marker2D = $Direction
@onready var introduction: Control = %Introduction
@onready var inventory: Control = %Inventory

func _ready() -> void:
	if GameManager.get_day_phase() < 1:
		var anim_player := %AnimationPlayer as AnimationPlayer
		anim_player.play("opening_animation")
		await anim_player.animation_finished
	#else:
		#position = Vector2(120, 146)


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

func show_dialog() -> void:
	if GameManager.get_day_phase() > dialog_finished_phase:
		return
	if GameManager.get_day_phase() == 3:
		GameManager.inc_day_phase()
	GameManager.start_dialogue()
	GameManager.show_dialogue(dialog_resource, dialog_start).tree_exited.connect(_on_dialog_finished)

func _on_dialog_finished() -> void:
	if GameManager.get_day_phase() > dialog_finished_phase:
		return
	GameManager.set_day_phase(1)

func _physics_process(delta: float) -> void:
	if GameManager.get_day_phase() > 1 and is_got_gun == false:
		is_got_gun = true
	if not GameManager.is_chatting() and not inventory.visible:
		handle_direction()
		handle_move()
	else :
		is_moving = false
	handle_animation()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("select"):
		var actionables = action_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()
			return
		#GameManager.start_dialogue()
		#GameManager.show_dialogue(load("res://scenes/day/dialogues/pick_up_gun.dialogue"), "title")

func get_mirrored_animation() -> String:
	var name_parts = animated_sprite_2d.animation.split("_")
	var animation = name_parts[0]
	var direction = ""
	match name_parts[1]:
		"front":
			direction = "back"
		"back":
			direction = "front"
		"left":
			direction = "right"
		"right":
			direction = "left"
		_:
			direction = "front"
	return animation + "_" + direction

func get_mirrored_frame():
	return animated_sprite_2d.frame


func _on_finder_area_entered(area: Area2D) -> void:
	print("found area entered")
	introduction.show_check()


func _on_finder_area_exited(area: Area2D) -> void:
	print("found area exited")
	introduction.hide_check()
