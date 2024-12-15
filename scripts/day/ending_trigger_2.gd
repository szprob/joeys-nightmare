extends Area2D

@onready var room_light: DirectionalLight2D = %RoomLight
@onready var white_layer: ColorRect = %WhiteLayer
var ending: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var character = get_tree().current_scene.get_node("/root/Game/PlayerDay") as Node2D
	room_light.energy = (380 - character.position.y) / 780 * 6.5
	white_layer.modulate.a = (380 - character.position.y) / 780


func _on_body_entered(body: Node2D) -> void:
	if is_instance_of(body, CharacterBody2D):
		ending = true
