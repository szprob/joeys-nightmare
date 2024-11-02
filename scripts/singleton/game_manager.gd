extends Node

# 需要预加载 ItemManager 脚本
const ItemManager = preload("res://scripts/singleton/item_manager.gd")
const PipelineManagerScript = preload("res://scripts/singleton/pipeline_manager.gd")

var item_manager : ItemManager
var pipeline_manager : PipelineManagerScript

var scan_lines_scene = preload("res://scenes/shader/crt.tscn")  # 直接预加载扫描线场景
# 添加背景音乐预加载
var bgm_player: AudioStreamPlayer

var game_state = {
	'score': 0,
	'last_scene_path': "",
	'current_respawn_point_x': null,
	'current_respawn_point_y': null,
	'respawn_enable':false,
	'archive_index': 1,
	'settings': {
		'full_screen': false,
		'scan_lines': true,
		'bgm_enabled': true  # 添加开关控制
	},
	'teleport_enable': true,
	# 0: 开场 1: 找寻身份证 2: 找寻枪 3: 第一次梦境就绪
	'day_phase' : 0,
	'is_door_open': false,
	'is_day_player_chatting' : false,
	# 玩家道具库存： 只存道具名称
	'inventory' : [],
	'teleport_type': 'day2dream',
	'target_scene': 'res://scenes/dreams/bigworld/bigworld01.tscn'
}

# 在文件开头添加 BGM 资源预加载
var bgm_resources = {
	"bgm": preload("res://assets/music/time_for_adventure.mp3"),  

}

func init_default_state():
	game_state = game_state.duplicate(true)  # 深度复制默认状态



func add_item(item_name:StringName)->void:
	game_state['inventory'].append(item_name)

func use_item(item_name:StringName) -> void:
	game_state['inventory'].erase(item_name)

func has_item(item_name:StringName) -> bool:
	return game_state['inventory'].has(item_name)

func get_items() -> Array[StringName]:
	return Array(game_state['inventory'], TYPE_STRING_NAME, &"", null)


func _ready() -> void:
	# 创建 ItemManager 实例时传入 self 作为参数
	item_manager = ItemManager.new(self)
	pipeline_manager = PipelineManagerScript.new(self)
	# 确保场景已被正确加载
	if not scan_lines_scene:
		push_error("扫描线场景未设置！请在检查器中设置scan_lines_scene")
		return
		
	# 添加场景树信号连接
	get_tree().node_added.connect(_on_node_added)
	
	# 初始化背景音乐播放器
	setup_bgm_player()
	
	init_default_state()
	apply_settings()
	
	# 添加这一行来自动开始播放BGM
	play_bgm("bgm")

func setup_bgm_player() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Music"  # 确保你的项目中有名为"Music"的音频总线
	# 添加这一行来设置循环播放
	bgm_player.stream_paused = false
	add_child(bgm_player)
	
# 修改 play_bgm 函数，支持通过名称播放 BGM
func play_bgm(bgm_name: String) -> void:
	if not game_state['settings']['bgm_enabled']:
		return
		
	if not bgm_resources.has(bgm_name):
		push_error("BGM 资源未找到：" + bgm_name)
		return
		
	var stream = bgm_resources[bgm_name]
	if bgm_player.stream != stream or not bgm_player.playing:
		bgm_player.stream = stream
		bgm_player.play()

func stop_bgm() -> void:
	bgm_player.stop()

func set_bgm_volume(volume: float) -> void:
	game_state['settings']['bgm_volume'] = volume
	bgm_player.volume_db = linear_to_db(volume)

func add_scan_lines_to_node(node: Node) -> void:
	# 防止重复添加和无限递归
	var parent = node.get_parent()
	# 检查节点及其所有父节点是否已经有扫描线
	var current_node = node
	while current_node:
		if current_node.get_node_or_null("ScanLines"):
			return  # 如果任何父节点已有扫描线，就不再添加
		current_node = current_node.get_parent()
	
	if not node.name == "ScanLines" and (not parent or parent.name != "ScanLines"):
		var scan_lines_instance = scan_lines_scene.instantiate()
		scan_lines_instance.name = "ScanLines"
		
		# 如果扫描线是 CanvasLayer，设置其 layer 属性
		if scan_lines_instance is CanvasLayer:
			scan_lines_instance.layer = 100
			
		node.add_child(scan_lines_instance)
		print("已添加扫描线到节点: ", node.name)

func _on_node_added(node: Node) -> void:
	# 当新节点被添加到场景树时，自动检查并添加扫描线
	if game_state['settings']['scan_lines']:
		# 跳过扫描线相关的节点
		var parent = node.get_parent()
		if node.name == "ScanLines" or (parent and parent.name == "ScanLines"):
			return
			
		# 只为根节点或特定组的节点添加扫描线
		if node.is_in_group("scan_lines"):
			add_scan_lines_to_node(node)

func on_fullscreen_toggled(toggled_on: bool) -> void:
	game_state['settings']['full_screen'] = toggled_on
	apply_settings()

#func on_music_volume_slider_value_changed(value: float) -> void:
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
#
#func on_sfx_volume_slider_value_changed(value: float) -> void:
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), value)

func on_scan_lines_toggled(toggled_on: bool) -> void:
	game_state['settings']['scan_lines'] = toggled_on
	apply_settings()

func apply_settings() -> void:
	# 应用全屏设置
	if game_state['settings']['full_screen']:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# 应用扫描线设置
	var scanline_nodes = get_tree().get_nodes_in_group("scan_lines")
	if game_state['settings']['scan_lines']:
		# 如果启用扫描线，确保所有需要的节点都有扫描线
		for node in scanline_nodes:
			add_scan_lines_to_node(node)
	else:
		# 如果禁用扫描线，移除所有现有的扫描线
		for node in scanline_nodes:
			var scan_lines = node.get_node_or_null("ScanLines")
			if scan_lines:
				scan_lines.queue_free()

func save_game_state():
	# 确保存档目录存在
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("save"):
		dir.make_dir("save")
	
	var archive_index = str(game_state['archive_index'])
	var file_path = "res://save/save_game"+archive_index+".json"
	
	# 在保存之前转换 Vector2
	var save_data = game_state.duplicate(true)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("游戏已成功保存")
	else:
		push_error("保存游戏失败：无法创建存档文件")

func load_game_state():
	var archive_index = str(game_state['archive_index'])
	var file_path = "res://save/save_game"+archive_index+".json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var save_text = file.get_as_text()
		var json = JSON.new()
		var result = json.parse(save_text)
		if result == OK:
			game_state = json.data
			pipeline_manager.sync_game_state(game_state)
		else:
			print("JSON Parse Error at line ", json.get_error_line())
			# 加载失败时初始化默认状态
			init_default_state()
		file.close()
	else:
		print("无法打开存档文件")
		init_default_state()


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
	
func is_door_open() -> bool:
	return game_state['is_door_open']

func test_print() -> void:
	print("hahahahahhahahaha")
