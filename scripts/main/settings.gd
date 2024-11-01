extends Control

var buttons = []
var current_index = 0

@onready var full_screen:CheckButton = $fullscreen
@onready var back_button: Button = $back_button
@onready var scan_lines:CheckButton = $scanlines

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.load_game_state()
	
	# 设置默认值（如果是首次运行）
	if !GameManager.game_state.has('settings'):
		GameManager.game_state['settings'] = {
			'full_screen': false,
			'scan_lines': true  # 默认开启扫描线
		}
	
	# 应用保存的设置
	full_screen.set_pressed_no_signal(GameManager.game_state['settings']['full_screen'])
	scan_lines.set_pressed_no_signal(GameManager.game_state['settings']['scan_lines'])
	
	# 立即应用设置效果
	GameManager.apply_settings()
	
	buttons = [full_screen, scan_lines, back_button]
	buttons[current_index].grab_focus()


func _on_back_button_pressed() -> void:
	GameManager.save_game_state()  # 保存设置
	get_tree().change_scene_to_file("res://scenes/main/start.tscn")

func _process(delta):
	if Input.is_action_just_pressed("down"):
		current_index = (current_index + 1) % buttons.size()
		buttons[current_index].grab_focus()
	elif Input.is_action_just_pressed("up"):
		current_index = (current_index - 1 + buttons.size()) % buttons.size()
		buttons[current_index].grab_focus()
	elif Input.is_action_just_pressed("main_scene_select"):
		if buttons[current_index] is Button:
			buttons[current_index].emit_signal("pressed")
		elif buttons[current_index] is CheckButton:
			buttons[current_index].set_pressed_no_signal(!buttons[current_index].is_pressed())
			buttons[current_index].emit_signal("toggled", buttons[current_index].is_pressed())


#func _on_fullscreen_option_item_selected(index: int) -> void:
	#GameManager.on_fullscreen_option_item_selected(index)
	#
#func _on_music_volume_slider_value_changed(value: float) -> void:
	#GameManager.on_music_volume_slider_value_changed(value)
#
#func _on_sfx_volume_slider_value_changed(value: float) -> void:
	#GameManager.on_sfx_volume_slider_value_changed(value)

func _on_scan_lines_toggled(toggled_on: bool) -> void:
	GameManager.on_scan_lines_toggled(toggled_on)

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	GameManager.on_fullscreen_toggled(toggled_on)
