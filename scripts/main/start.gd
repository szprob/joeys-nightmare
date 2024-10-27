extends Node2D

var buttons = []
var current_index = 0
@onready var new_button: Button = $new
@onready var load_button: Button = $load
@onready var set_button: Button = $set
@onready var quit_button: Button = $quit


func _ready():
	buttons = [new_button, load_button,set_button, quit_button]  # Replace with your actual button paths
	buttons[current_index].grab_focus()

func _process(delta):
	if Input.is_action_just_pressed("down"):
		current_index = (current_index + 1) % buttons.size()
		buttons[current_index].grab_focus()
	elif Input.is_action_just_pressed("up"):
		current_index = (current_index - 1 + buttons.size()) % buttons.size()
		buttons[current_index].grab_focus()
	elif Input.is_action_just_pressed("main_scene_select"):
		buttons[current_index].emit_signal("pressed")

func _on_new_pressed() -> void:
	#GameManager.game_state['archive_index'] = 1 + GameManager.game_state['archive_index']
	GameManager.save_game_state()
	get_tree().change_scene_to_file("res://scenes/dreams/stage001/game001.tscn")


func _on_load_pressed() -> void:
	GameManager.load_game_state()
	GameManager.apply_settings()
	print('读取成功,复活点:',GameManager.game_state['current_respawn_point'])
	get_tree().change_scene_to_file("res://scenes/dreams/stage001/game001.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_set_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/settings.tscn")
