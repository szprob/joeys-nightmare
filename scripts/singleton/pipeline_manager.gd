class_name Pipeline
extends Node

var parent: GameManager

# 存储游戏进度相关信息
var pipeline = {
	"current_node": "",  # 当前节点
	"next_node": "",     # 下一个节点
	"visited_nodes": [], # 已访问节点
	"key_items": {},     # 关键道具
	"flags": {},         # 游戏标记
}

func _init(parent_node: Node):
	parent = parent_node
	sync_game_state()

func sync_game_state(game_state = null) -> void:
	if game_state:
		pipeline = game_state['pipeline']
	else:
		parent.game_state['pipeline'] = pipeline

# 设置当前节点
func set_current_node(node_name: String) -> void:
	pipeline.current_node = node_name
	if not node_name in pipeline.visited_nodes:
		pipeline.visited_nodes.append(node_name)

# 设置下一个节点
func set_next_node(node_name: String) -> void:
	pipeline.next_node = node_name

# 添加关键道具
func add_key_item(item_name: String, item_data = null) -> void:
	pipeline.key_items[item_name] = item_data

# 检查是否有某个关键道具
func has_key_item(item_name: String) -> bool:
	return item_name in pipeline.key_items

# 设置游戏标记
func set_flag(flag_name: String, value = true) -> void:
	pipeline.flags[flag_name] = value

# 获取游戏标记
func get_flag(flag_name: String) -> bool:
	return pipeline.flags.get(flag_name, false)

# 检查节点是否已访问
func has_visited_node(node_name: String) -> bool:
	return node_name in pipeline.visited_nodes

# 获取当前进度信息
func get_progress_data() -> Dictionary:
	return pipeline
