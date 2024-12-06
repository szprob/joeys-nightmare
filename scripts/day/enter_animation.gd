extends Sprite2D

var triggered: bool = false
@onready var actionable: Area2D = $Actionable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_actionable_body_entered(body: Node2D) -> void:
	if is_instance_of(body, CharacterBody2D):
		if not triggered:
			var anim_player := %AnimationPlayer as AnimationPlayer
			anim_player.play("look_around")
			await anim_player.animation_finished
			triggered = true
			actionable.action()
			GameManager.set_skill_enabled("second_jump_enabled", true)
			queue_free()
	else:
		print(typeof(body))
