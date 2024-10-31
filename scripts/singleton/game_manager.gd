extends Node

@export var scan_lines_scene: PackedScene


var game_state = {
	'score': 0,
	'current_respawn_point': Vector2(-74, -39),
	'respawn_enable':false,
	'archive_index': 1,
	'settings': {
		'full_screen': false,
		'scan_lines': true
	},
	'teleport_enable': true
}

func init_default_state():
	game_state = game_state.duplicate(true)  # 深度复制默认状态

func _ready() -> void:
	init_default_state()
	apply_settings()
		


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
	var scanline_nodes = get_tree().get_nodes_in_group("scanlines")
	if scanline_nodes.is_empty():
		push_warning("没有找到带有 'scanlines' 组的节点")
		return
		
	for node in scanline_nodes:
		var existing_scan_lines = node.get_node_or_null("ScanLines")
		
		if toggled_on:
			if not existing_scan_lines:
				var scan_lines_instance = scan_lines_scene.instantiate()
				scan_lines_instance.name = "ScanLines"
				node.add_child(scan_lines_instance)
		else:
			if existing_scan_lines:
				existing_scan_lines.queue_free()

	game_state['settings']['scan_lines'] = toggled_on



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
			# 正确赋值加载的游戏状态
			game_state = json.data
		else:
			print("JSON Parse Error at line ", json.get_error_line())
			# 加载失败时初始化默认状态
			init_default_state()
		file.close()
	else:
		print("无法打开存档文件")
		init_default_state()
