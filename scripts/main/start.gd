extends Node2D

@export var transition_scene: String = "res://scenes/modules/checkpoints/transition.tscn"  # 添加过渡场景路径
@export var target_scene: String = "res://scenes/dreams/bigworldv2/intro.tscn"

var buttons = []
var current_index = 0

@onready var new_button: Button = $new
@onready var load_button: Button = $load
@onready var set_button: Button = $set
@onready var quit_button: Button = $quit
@onready var logo: Sprite2D = $Sprite2D
@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	GameManager.setup_bgm_player()
	GameManager.play_bgm("bgm")
	buttons = [new_button, load_button, set_button, quit_button]
	buttons[current_index].grab_focus()
	new_button.pressed.connect(_on_new_pressed)
	load_button.pressed.connect(_on_load_pressed)
	set_button.pressed.connect(_on_set_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func play_sfx():
	if sfx_player:
		sfx_player.play()

func _process(delta):
	if Input.is_action_just_pressed("down"):
		current_index = (current_index + 1) % buttons.size()
		buttons[current_index].grab_focus()
		play_sfx()
	elif Input.is_action_just_pressed("up"):
		current_index = (current_index - 1 + buttons.size()) % buttons.size()
		buttons[current_index].grab_focus()
		play_sfx()
	elif Input.is_action_just_pressed("main_scene_select"):
		buttons[current_index].emit_signal("pressed")
		play_sfx()

func _on_new_pressed() -> void:
	play_sfx()
	GameManager.init_default_state()
	GameManager.game_state['target_scene'] = target_scene
	GameManager.game_state['teleport_type'] = 'day2dream'
	GameManager.save_game_state()
	get_tree().change_scene_to_file(transition_scene)


func _on_load_pressed() -> void:
	play_sfx()
	GameManager.load_game_state()
	GameManager.apply_settings()
	# 创建过渡场景实例
	get_tree().change_scene_to_file(transition_scene)

func _on_quit_pressed() -> void:
	play_sfx()
	get_tree().quit()


func _on_set_pressed() -> void:
	play_sfx()
	get_tree().change_scene_to_file("res://scenes/main/settings.tscn")
