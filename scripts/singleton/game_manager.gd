extends Node

var score: int = 0
var current_respawn_point: NodePath


func save_game_state():
	var save_data = {
		"score": score,
		"respawn_point": current_respawn_point
	}
	var file = FileAccess.open("user://save_game.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_game_state():
	var file = FileAccess.open("user://save_game.json", FileAccess.READ)
	if file:
		var save_text = file.get_as_text()
		var json = JSON.new()
		var result = json.parse(save_text)
		if result.error == OK:
			var save_data = json.data
			score = save_data["score"]
			current_respawn_point = save_data["respawn_point"]
		else:
			print("JSON Parse Error at line ",json.get_error_line())
		file.close()
