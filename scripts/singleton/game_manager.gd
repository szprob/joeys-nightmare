extends Node

var game_state  = {
	'score' = 0 , # 积分
	'current_respawn_point' = Vector2(-74,-39),# 重生点位置
	'archive_index' = 1 ,# 存档索引
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
