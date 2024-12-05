extends Node2D

@export var character: CharacterBody2D
@export var opacity_factor: float = 0.02
@onready var refelection: AnimatedSprite2D = $Refelection_Animated

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var distance_y = character.global_position.y - global_position.y
	_update_refelection_position(distance_y)
	_update_refelection_opacity(distance_y)
	_update_refelection_animation()

func _update_refelection_position(distance_y):
	refelection.global_position = Vector2(
		character.global_position.x,
		global_position.y - distance_y + 10
	)

func _update_refelection_animation():
	refelection.animation = character.get_mirrored_animation()
	refelection.frame = character.get_mirrored_frame()

func _update_refelection_opacity(distance_y):
	refelection.modulate.a = 1.0 - distance_y * opacity_factor
