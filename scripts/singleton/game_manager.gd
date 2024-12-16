extends Node

# 需要预加载 ItemManager 脚本
const ItemManager = preload("res://scripts/singleton/item_manager.gd")
const PipelineManagerScript = preload("res://scripts/singleton/pipeline_manager.gd")

var item_manager: ItemManager
var pipeline_manager: PipelineManagerScript

var scan_lines_scene = preload("res://scenes/shader/crt.tscn") # 直接预加载扫描线场景
var pause_scene = preload("res://scenes/main/pause.tscn")
# 添加背景音乐预加载
var bgm_player: AudioStreamPlayer

signal camera_shake_requested(strength: float, duration: float)
signal die_requested()

# 在文件开头添加 BGM 资源预加载
var bgm_resources = {
	"bgm": preload("res://assets/music/main Nightmare Prelude.mp3"),
	'intro': preload("res://assets/music/intro1.wav"),
	'chase': preload("res://assets/music/chase0.wav"),
	'cave': preload("res://assets/music/cave.mp3"),
	'church': preload("res://assets/music/Karl Richter - Toccata and Fugue in D minor, BWV 565Fugue.mp3"),
	'end': preload("res://assets/music/True Self Dream.mp3"),
	'boss': preload("res://assets/music/boss2.wav"),
	# 'run': preload("res://assets/music/Chasing Shadows.mp3"),	
	'run': preload("res://assets/music/run-dragon-back.mp3"),
}


var dialogue_image_storage = {
	"joey_normal": "res://assets/sprites/day/character/JOEY帅气版.png",
	"joey_happy": "res://assets/sprites/day/character/joey帅气版2.png",
	"doctor": "res://assets/sprites/day/character/642.png",
	"radio": "res://assets/sprites/day/enrich/收音机1.png",
	"id_card": "res://assets/sprites/day/room/身份证.png",
	"shoe": "res://assets/sprites/day/new_room/AJ.png",
	"door": "res://assets/sprites/day/buttons/D.png",
	"draw": "res://assets/sprites/day/buttons/D.png",
	"water_gun": "res://assets/sprites/day/room/gun.png",
	"telephone": "res://assets/sprites/day/new_room/zhuoji.png",
	"note1": "res://assets/sprites/day/enrich/note1.png",
	"safe_close": "res://assets/sprites/day/enrich/safe1.png",
	"safe_open1": "res://assets/sprites/day/enrich/safe2.png",
	"safe_open2": "res://assets/sprites/day/enrich/safe3.png",
	"room3_door_close": "res://assets/sprites/day/new_room/room3_door_close.png",
	"room3_door_open": "res://assets/sprites/day/new_room/room3_door_open.png",
	"macintosh": "res://assets/sprites/day/enrich/macintosh.png",
	"tracy": "res://assets/sprites/day/character/结局女主.png",
	"tracy_smile": "res://assets/sprites/day/character/tracy_smile.png",
	"diary": "res://assets/sprites/day/enrich/日记本1.png",
	"message": "res://assets/sprites/day/enrich/信封1.png"
}
var game_state = {}
var game_state_cache = {'can_detect_kill_zone': true,
	'do_detect_teleport': true,
	'should_die': true,
	'bmg_set': false,
	'inventory_visible': false,
	'code': ''}

func init_default_state():
	var game_state2 = {
		'score': 0,
		'last_scene_path': "",
		'current_respawn_point_x': null,
		'current_respawn_point_y': null,
		'respawn_enable': false,
		'archive_index': 1,
		'settings': {
			'full_screen': true,
			'scan_lines': true,
			'bgm_enabled': true # 添加开关控制
		},
		'teleport_enable': true,
		# 0: 开场 1: 找寻身份证 2: 找寻枪 3: 第一次梦境就绪
		'day_phase': 0,
		'is_door_open': false,
		'is_day_player_chatting': false,
		# 玩家道具库存： 只存道具名称
		'inventory': [],
		'teleport_type': 'day2dream',
		'has_slept': false,
		'target_scene': 'res://scenes/dreams/bigworld/bigworld01.tscn',
		'is_paused': false,
		'skills': {
			'second_jump_enabled': false
		},
		'boss': {'boos1': {'current_area_index': 0}},
		'npc_dialogue_list': [],
		'laji': '',
		'number_deaths': 0,
		'doors_opened': [],
		# 0: 未放水 1: 放水中 2: 放完水
		'tub_water_phase': 0,
		'light1_visble': true,
		'light2_visble': true,
		'light3_visble': true,
		'fire_extincted': false,
		"is_room2_entered": false,
		"water_gun_filled": false,
		"left_door_opened": false,
		"right_door_opened": false,
		"all_light_off": false,
		"room3_door_open": false,
		'play_time_seconds': 0, # 添加游戏时间记录（秒）
		'finish': false,
	}
	game_state = game_state2.duplicate(true) # 深度复制默认状态

var _skill_cache := {}

func set_skill_enabled(skill_name: StringName, value: bool) -> void:
	game_state['skills'][skill_name] = value
	_skill_cache[skill_name] = value

func is_skill_enabled(skill_name: StringName) -> bool:
	if skill_name in _skill_cache:
		return _skill_cache[skill_name]
	var value = game_state['skills'].get(skill_name, false)
	_skill_cache[skill_name] = value
	return value

func add_item(item_name: StringName) -> void:
	print("获得物品： ", item_name)
	game_state['inventory'].append(item_name)
	print("当前物品栏： ", game_state['inventory'])
	print("是否包含物品[", item_name, "]: ", has_item(item_name))

func use_item(item_name: StringName) -> void:
	game_state['inventory'].erase(item_name)

func has_item(item_name: StringName) -> bool:
	return game_state['inventory'].has(item_name)

func get_items() -> Array[StringName]:
	return Array(game_state['inventory'], TYPE_STRING_NAME, &"", null)


func _ready() -> void:
	init_default_state() # 确保这是第一个调用的函数
	
	# 创建 ItemManager 实例时传入 self 作为参数
	item_manager = ItemManager.new(self)
	pipeline_manager = PipelineManagerScript.new(self)
	
	# 确保场景已被正确加载
	if not scan_lines_scene:
		push_error("扫描线场景未设置！请在检查器中设置scan_lines_scene")
		return
		
	# 添加场景树信号连接
	get_tree().node_added.connect(_on_node_added)
	
	apply_settings()

func setup_bgm_player() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Music" # 确保你的项目中有名为"Music"的音频总线
	bgm_player.stream_paused = false
	# 设置音量为原来的25%（-12分贝）
	bgm_player.volume_db = -12
	# 添加这一行来设置循环播放
	bgm_player.finished.connect(func(): bgm_player.play())
	add_child(bgm_player)
	game_state_cache['bmg_set'] = true
	
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
	if bgm_player:
		bgm_player.stop()
		bgm_player.queue_free()
		game_state_cache['bmg_set'] = false

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
			return # 如果任何父节点已有扫描线，就不再添加
		current_node = current_node.get_parent()
	
	if not node.name == "ScanLines" and (not parent or parent.name != "ScanLines"):
		var scan_lines_instance = scan_lines_scene.instantiate()
		scan_lines_instance.name = "ScanLines"
		
		# 如果扫描线是 CanvasLayer，设置其 layer 属性
		if scan_lines_instance is CanvasLayer:
			scan_lines_instance.layer = 100
			
		node.add_child(scan_lines_instance)

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
	get_tree().paused = true
	
	# 应用全屏设置
	if game_state['settings']['full_screen']:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	get_tree().paused = false
	
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
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("save"):
		dir.make_dir("save")
	
	var archive_index = str(game_state['archive_index'])
	var file_path = "user://save/save_game" + archive_index + ".json"
	
	# 在保存之前转换 Vector2
	var save_data = game_state.duplicate(true)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func load_game_state():
	var archive_index = str(game_state['archive_index'])
	var file_path = "user://save/save_game" + archive_index + ".json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var save_text = file.get_as_text()
		var json = JSON.new()
		var result = json.parse(save_text)
		if result == OK:
			game_state = json.data
			# pipeline_manager.sync_game_state(game_state)
		else:
			# 加载失败时初始化默认状态
			init_default_state()
		file.close()
		_skill_cache.clear()
	else:
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

func get_tub_water_phase() -> int:
	return game_state['tub_water_phase']
	
func inc_tub_water_phase() -> void:
	game_state['tub_water_phase'] += 1
	
func enter_room2() -> void:
	game_state['is_room2_entered'] = true

func is_room2_entered() -> bool:
	return game_state['is_room2_entered']

func fill_water_gun() -> void:
	game_state['water_gun_filled'] = true
	
func is_water_gun_filled() -> bool:
	return game_state['water_gun_filled']
	
func open_left_door() -> void:
	game_state['left_door_opened'] = true

func is_left_door_opened() -> bool:
	return game_state['left_door_opened']

func start_dialogue() -> void:
	game_state['is_day_player_chatting'] = true

func end_dialogue() -> void:
	game_state['is_day_player_chatting'] = false
	
func is_door_open() -> bool:
	return game_state['is_door_open']

func is_all_light_off() -> bool:
	return game_state['all_light_off']

func is_light1_visible() -> bool:
	return game_state['light1_visble']
	
func is_light2_visible() -> bool:
	return game_state['light2_visble']
	
func is_light3_visible() -> bool:
	return game_state['light3_visble']

func get_light_visble(index: int) -> bool:
	if index == 1:
		return is_light1_visible()
	elif index == 2:
		return is_light2_visible()
	else:
		return is_light3_visible()

func set_light_visble(visble_value: bool, index: int) -> void:
	if index == 1:
		set_light1_visble(visble_value)
	elif index == 2:
		set_light2_visble(visble_value)
	else:
		set_light3_visble(visble_value)

func set_light1_visble(visble_value: bool) -> void:
	game_state['light1_visble'] = visble_value
	
func set_light2_visble(visble_value: bool) -> void:
	game_state['light2_visble'] = visble_value
	
func set_light3_visble(visble_value: bool) -> void:
	game_state['light3_visble'] = visble_value
	
func is_fire_extincted() -> bool:
	return game_state['fire_extincted']
	
func extinct_fire() -> void:
	game_state['fire_extincted'] = true

func is_room2_cleared() -> bool:
	return has_item("信") and has_item("钩爪") and has_item("水枪") and game_state['all_light_off']

func is_room3_door_open() -> bool:
	return game_state['room3_door_open']

func open_room3_door() -> void:
	print(get_tree().current_scene.name)
	var door_node = get_node("/root/Game/Room3/Door1") as AnimatedSprite2D
	door_node.open_door()
	game_state['room3_door_open'] = true

func switch_day_to_dream(scene_file_path: String) -> void:
	game_state['target_scene'] = scene_file_path
	game_state['teleport_type'] = "day2dream"
	end_dialogue()
	GameManager.save_game_state()
	get_tree().change_scene_to_file("res://scenes/modules/checkpoints/transition.tscn")

func enter_day_scene(scene_file_path: String) -> void:
	end_dialogue()
	GameManager.save_game_state()
	get_tree().change_scene_to_file(scene_file_path)
	
func back_to_room3() -> void:
	end_dialogue()
	GameManager.save_game_state()
	var new_scene = load("res://scenes/day/game/game.tscn").instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.free()
	get_tree().current_scene = new_scene
	get_tree().change_scene_to_file(scene_file_path)
	
	var player = new_scene.get_node("PlayerDay")
	player.position = Vector2(-243, 398)

func show_hello() -> void:
	var hello_animation = get_node("/root/MacRoom/Hello/HelloAnimation") as AnimationPlayer
	hello_animation.play("appear")

# 添加暂停相关的方法
func _input(event: InputEvent) -> void:
	# 确保只在按键事件时调用 is_action_just_pressed
	if event.is_pressed():
		if Input.is_action_just_pressed("esc") and not game_state_cache['inventory_visible'] and not is_chatting():
			if not get_tree().current_scene.is_in_group("no_pause"):
				toggle_pause_menu()
			else:
				print("当前场景不允许暂停")
		
		var current_file_name = get_tree().current_scene.scene_file_path
		if 'day' not in current_file_name and 'transition' not in current_file_name:
			if Input.is_action_just_pressed("reload"):
				print("reload")
				get_tree().change_scene_to_file(GameManager.game_state['last_scene_path'])

func set_inventory_visible(value: bool) -> void:
	game_state_cache['inventory_visible'] = value


func toggle_pause_menu() -> void:
	if not game_state.has("is_paused"):
		game_state["is_paused"] = false
		
	if game_state['is_paused']:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:

	# 先检查是否已经存在暂停菜单
	var current_scene = get_tree().current_scene
	var existing_pause = current_scene.get_node_or_null("PauseMenu")
	if existing_pause:
		print("暂停菜单已存在，跳过创建")
		return
		
	game_state['is_paused'] = true
	get_tree().paused = true
	
	var pause_scene_instance = pause_scene.instantiate()
	pause_scene_instance.name = "PauseMenu"
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "PauseMenu" # 给 CanvasLayer 也设置相同的名称
	canvas_layer.layer = 99
	canvas_layer.add_child(pause_scene_instance)
	current_scene.add_child(canvas_layer)

func resume_game() -> void:
	print("正在恢复游戏...")
	game_state['is_paused'] = false
	
	# 查找并删除所有暂停菜单实例
	var current_scene = get_tree().current_scene
	var pause_menu = current_scene.get_node_or_null("PauseMenu")
	if pause_menu:
		pause_menu.queue_free()
	
	get_tree().paused = false
	print("游戏已恢复")


func read_txt_to_list(file_path: String) -> Array:
	var content = []
	
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		while !file.eof_reached():
			var line = file.get_line()
			content.append(line)
		file.close()
	
	return content

# 添加计时器回调函数
func _on_play_time_timer_timeout() -> void:
	if not game_state['is_paused']: # 暂停时不计时
		game_state['play_time_seconds'] += 1

# 添加获取格式化时间的函数
func get_formatted_play_time() -> String:
	var total_seconds = game_state['play_time_seconds']
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var seconds = total_seconds % 60
	
	return "%02d:%02d:%02d" % [hours, minutes, seconds]
