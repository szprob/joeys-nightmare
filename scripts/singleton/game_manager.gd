extends Node

var game_state  = {
	'score' = 0 , # 积分
	'current_respawn_point' = Vector2(-74,-39),# 重生点位置
	'archive_index' = 1 ,# 存档索引
	# 0: 开场 1: 找寻身份证 2: 找寻枪 3: 第一次梦境就绪
	'day_phase' = 0,
	'is_day_player_chatting' = false,
	# 玩家道具库存： 只存道具名称
	'inventory' = []
}

func add_item(item_name:StringName)->void:
	game_state['inventory'].append(item_name)

func use_item(item_name:StringName) -> void:
	game_state['inventory'].erase(item_name)

func has_item(item_name:StringName) -> bool:
	return game_state['inventory'].has(item_name)

func get_items() -> Array[StringName]:
	return Array(game_state['inventory'], TYPE_STRING_NAME, &"", null)

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
	var is_small_window = true
	# var is_small_window: bool = ProjectSettings.get_setting("display/window/size/viewport_width") < 400
	var balloon_path: String = "res://dialogue_label/dialogue_balloon/small_example_balloon.tscn" if is_small_window else "res://dialogue_label/dialogue_balloon/example_balloon.tscn"
	return balloon_path

func show_dialogue(resource: DialogueResource, title: String = "", extra_game_states: Array = []) -> CanvasLayer:
	var balloon: Node = load(_get_balloon_path()).instantiate()
	get_current_scene.call().add_child(balloon)
	balloon.start(resource, title, extra_game_states)
	return balloon

func is_chatting() -> bool:
	return game_state['is_day_player_chatting']

func get_day_phase() -> int:
	return game_state['day_phase']
	
func set_day_phase(phase_number: int) -> void:
	game_state['day_phase'] = phase_number

func inc_day_phase() -> void:
	game_state['day_phase'] += 1

func start_dialogue() -> void:
	game_state['is_day_player_chatting'] = true

func end_dialogue() -> void:
	game_state['is_day_player_chatting'] = false

func test_print() -> void:
	print("hahahahahhahahaha")
