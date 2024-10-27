extends Node


var settings = {
	'full_screen' = false,#'WINDOWED',
	'scan_lines' = true,
}


var game_state  = {
	'score' = 0 , # 积分
	'current_respawn_point' = Vector2(-74,-39),# 重生点位置
	'archive_index' = 1 ,# 存档索引
	# settings
	'settings' = settings,
}


func on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED)
	game_state['settings']['full_screen'] = toggled_on

#func on_music_volume_slider_value_changed(value: float) -> void:
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
#
#func on_sfx_volume_slider_value_changed(value: float) -> void:
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)

func on_scan_lines_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func apply_settings():
	on_fullscreen_toggled(game_state['settings']['full_screen'])
	on_scan_lines_toggled(game_state['settings']['scan_lines'])

func save_game_state():
	var archive_index = str(game_state['archive_index'])
	var file_path = "res://save/save_game"+archive_index+".json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(game_state))
	file.close()

func load_game_state():
	var archive_index = str(game_state['archive_index'])
	var file_path = "res://save/save_game"+archive_index+".json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var save_text = file.get_as_text()
		var json = JSON.new()
		var result = json.parse(save_text)
		if result == OK:
			var game_state = json.data
		else:
			print("JSON Parse Error at line ",json.get_error_line())
		file.close()
