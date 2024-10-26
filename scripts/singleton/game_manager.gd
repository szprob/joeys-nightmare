extends Node

var game_state  = {
	'score' = 0 , # 积分
	'current_respawn_point' = Vector2(-74,-39),# 重生点位置
	'archive_index' = 1 ,# 存档索引
	'day_phase' = 0,
	'is_day_player_chatting' = false
}

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

var get_current_scene: Callable = func():
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		current_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	return current_scene

func _get_balloon_path() -> String:
	var is_small_window: bool = ProjectSettings.get_setting("display/window/size/viewport_width") < 400
	var balloon_path: String = "res://dialogue_label/dialogue_balloon/small_example_balloon.tscn" if is_small_window else "res://dialogue_label/dialogue_balloon/example_balloon.tscn"
	return balloon_path

func show_dialogue(resource: DialogueResource, title: String = "", extra_game_states: Array = []) -> CanvasLayer:
	var balloon: Node = load(_get_balloon_path()).instantiate()
	get_current_scene.call().add_child(balloon)
	balloon.start(resource, title, extra_game_states)
	return balloon
