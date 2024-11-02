extends Area2D


@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "title"

func action() -> void:
	GameManager.start_dialogue()
	GameManager.show_dialogue(dialogue_resource, dialogue_start)
