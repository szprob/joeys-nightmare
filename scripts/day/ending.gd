extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if is_instance_of(body, CharacterBody2D):
		GameManager.start_dialogue()
		GameManager.show_dialogue(load("res://scenes/day/dialogues/ending.dialogue"), "ending")