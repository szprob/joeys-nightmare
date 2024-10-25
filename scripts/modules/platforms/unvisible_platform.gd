extends AnimatableBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.visible = false


func _on_detection_body_entered(body: Node2D) -> void:
	print("Body entered: ", body.name)
	if body is CharacterBody2D:
		sprite_2d.visible = true
	
