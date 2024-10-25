extends Control

@onready var fullscreen_option: OptionButton = $fullscreen_option
@onready var music_volume_slider: HSlider = $music_volume_slider
@onready var sfx_volume_slider: HSlider = $sfx_volume_slider
@onready var back_button: Button = $back_button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.load_game_state()
	# 初始化控件状态
	fullscreen_option.add_item("WINDOWED")
	fullscreen_option.add_item("MAXIMIZED")
	fullscreen_option.add_item("FULLSCREEN")
	fullscreen_option.add_item("EXCLUSIVE_FULLSCREEN")
	fullscreen_option.select(GameManager.game_state['fullscreen_option'])
	_on_fullscreen_option_item_selected(GameManager.game_state['fullscreen_option'])
	music_volume_slider.value=GameManager.game_state['music_volume_slider']
	sfx_volume_slider.value = GameManager.game_state['sfx_volume_slider']
	#music_volume_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	#sfx_volume_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	# 设置控件可以获取焦点
	fullscreen_option.focus_mode = Control.FOCUS_ALL
	music_volume_slider.focus_mode = Control.FOCUS_ALL
	sfx_volume_slider.focus_mode = Control.FOCUS_ALL
	back_button.focus_mode = Control.FOCUS_ALL


func _on_back_button_pressed() -> void:
	GameManager.game_state['fullscreen_option'] = fullscreen_option.get_selected_id()
	GameManager.game_state['music_volume_slider'] = music_volume_slider.value
	GameManager.game_state['sfx_volume_slider'] = sfx_volume_slider.value
	GameManager.save_game_state()
	# 切换场景
	get_tree().change_scene_to_file("res://scenes/main/start.tscn")


func _on_fullscreen_option_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED)
		2:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
		3:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)

# 处理键盘输入
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			if event.scancode == KEY_UP:
				navigate_focus_up()
			elif event.scancode == KEY_DOWN:
				navigate_focus_down()
			elif event.scancode == KEY_LEFT:
				change_slider_value(-1)
			elif event.scancode == KEY_RIGHT:
				change_slider_value(1)
			elif event.scancode == KEY_ENTER:
				if get_viewport().gui_get_focus_owner()  == back_button:
					_on_back_button_pressed()

# 导航焦点向上
func navigate_focus_up() -> void:
	var current_focus = get_viewport().gui_get_focus_owner()
	if current_focus == fullscreen_option:
		back_button.grab_focus()
	elif current_focus == music_volume_slider:
		fullscreen_option.grab_focus()
	elif current_focus == sfx_volume_slider:
		music_volume_slider.grab_focus()
	elif current_focus == back_button:
		sfx_volume_slider.grab_focus()

# 导航焦点向下
func navigate_focus_down() -> void:
	var current_focus = get_viewport().gui_get_focus_owner()
	if current_focus == fullscreen_option:
		music_volume_slider.grab_focus()
	elif current_focus == music_volume_slider:
		sfx_volume_slider.grab_focus()
	elif current_focus == sfx_volume_slider:
		back_button.grab_focus()
	elif current_focus == back_button:
		fullscreen_option.grab_focus()

# 改变滑块值
func change_slider_value(delta: float) -> void:
	var current_focus = get_viewport().gui_get_focus_owner()
	if current_focus == music_volume_slider:
		music_volume_slider.value += delta
	elif current_focus == sfx_volume_slider:
		sfx_volume_slider.value += delta
