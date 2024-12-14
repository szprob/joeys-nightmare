extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(GameManager.is_light3_visible())
	if GameManager.is_all_light_off():
		return
	if GameManager.is_light1_visible() or GameManager.is_light2_visible() or GameManager.is_light3_visible() or !GameManager.is_fire_extincted():
		return
	GameManager.game_state['all_light_off'] = true
