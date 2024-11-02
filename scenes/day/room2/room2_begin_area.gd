extends "res://scripts/actionable.gd"


func _ready() -> void:
	body_entered.connect(_on_body_entered)



func _on_body_entered(body) -> void:
	action()


func action() -> void:
	var anim_player := %AnimationPlayer as AnimationPlayer
	anim_player.play("look_around")
	await anim_player.animation_finished

	super()
	get_parent().queue_free()
