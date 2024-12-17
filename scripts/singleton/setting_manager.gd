class_name SettingsManager
extends Node
var parent: GameManager


var scan_lines_scene = preload("res://scenes/shader/crt.tscn")
var bgm_player: AudioStreamPlayer
var bgm_resources = {
	"bgm": preload("res://assets/music/time_for_adventure.mp3"),
}

var settings = {
	'full_screen': false,
	'scan_lines': true, 
	'bgm_enabled': true,
	'bgm_volume': 1.0
}

func sync_settings_to_game_state() -> void:
	parent.game_state['settings'] = settings

func _init(parent_node: Node):
	parent = parent_node
	sync_settings_to_game_state()
	setup_bgm_player(parent)

func _ready() -> void:
	# 等待一帧以确保场景树已经准备好
	await get_tree().process_frame
	apply_settings()

func setup_bgm_player(game_manager) -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Music"
	bgm_player.stream_paused = false
	game_manager.add_child(bgm_player)

# BGM相关函数
func play_bgm(bgm_name: String) -> void:
	if not settings['bgm_enabled']:
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
	settings['bgm_volume'] = volume
	bgm_player.volume_db = linear_to_db(volume)

# 扫描线相关函数
func add_scan_lines_to_node(node: Node) -> void:
	var node_parent = node.get_parent()
	var current_node = node
	while current_node:
		if current_node.get_node_or_null("ScanLines"):
			return
		current_node = current_node.get_parent()
	
	if not node.name == "ScanLines" and (not node_parent or node_parent.name != "ScanLines"):
		var scan_lines_instance = scan_lines_scene.instantiate()
		scan_lines_instance.name = "ScanLines"
		
		if scan_lines_instance is CanvasLayer:
			scan_lines_instance.layer = 100
			
		node.add_child(scan_lines_instance)

func on_fullscreen_toggled(toggled_on: bool) -> void:
	settings['full_screen'] = toggled_on
	sync_settings_to_game_state()
	apply_settings()

func on_scan_lines_toggled(toggled_on: bool) -> void:
	settings['scan_lines'] = toggled_on
	sync_settings_to_game_state()
	apply_settings()

# 设置相关函数
func apply_settings() -> void:
	var tree = get_tree()
	if not tree:
		return
		
	if settings['full_screen']:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	var scanline_nodes = tree.get_nodes_in_group("scan_lines")
	if settings['scan_lines']:
		for node in scanline_nodes:
			add_scan_lines_to_node(node)
	else:
		var all_nodes = tree.get_nodes_in_group("scan_lines")
		for node in all_nodes:
			var current_node = node
			while current_node:
				var scan_lines = current_node.get_node_or_null("ScanLines")
				if scan_lines:
					scan_lines.queue_free()
				current_node = current_node.get_parent()
