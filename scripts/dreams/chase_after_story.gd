extends Node2D

@export var player: Node2D # 玩家节点
@export var npc: Node2D # NPC节点
# @export var subtitle_label: Label # 字幕标签
@export var camera: Camera2D
@export var subtitle_container: Control
@export var subtitle_label: Label
@export var transition_scene: String = "res://scenes/modules/checkpoints/transition.tscn" # 添加过渡场景路径


var subtitles = [
	{"time": 0, "text": "A* studio presents"},
	{"time": 4, "text": "Team members"},
	{"time": 6, "text": "Producer and Level Design: \n Hougang Zhao"},
	{"time": 10, "text": "Programming: \n Ze song  Ziyi pan"},
	{"time": 14, "text": "Art: \n Xiao Cao  Wei Chen"},
	{"time": 18, "text": "Day Levels: \n YuChen Huang"},
	{"time": 22, "text": "Special Thanks: \n Friends and Family of GI Team"}
]

var current_subtitle = 0
var scene_timer = 0.0

func _ready():

	if not GameManager.game_state_cache['bmg_set']:
		GameManager.setup_bgm_player()
	GameManager.play_bgm('run')
	# 开始自动奔跑
	player.start_auto_run()
	npc.start_auto_run()
	
	# 初始化字幕
	subtitle_label.text = ""
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _process(delta):
	scene_timer += delta
	
	if camera:
		var viewport_rect = get_viewport_rect()
		var screen_center_x = viewport_rect.size.x / 2
		var screen_center_y = viewport_rect.size.y * 0.6
		# 考虑字幕容器自身的大小来实现真正的居中
		subtitle_container.position = Vector2(
			screen_center_x - subtitle_container.size.x / 2,
			screen_center_y
		)

	# 更新字幕
	if current_subtitle < subtitles.size():
		if scene_timer >= subtitles[current_subtitle]["time"]:
			subtitle_label.text = subtitles[current_subtitle]["text"]
			current_subtitle += 1
	
	# 场景结束条件（例如：10秒后）
	if scene_timer >= 30.0:
		end_scene()

func end_scene():
	player.stop_auto_run()
	if npc.has_method("stop_auto_run"):
		npc.stop_auto_run()
	# 这里可以切换到下一个场景或触发其他事件
	GameManager.game_state['target_scene'] = "res://scenes/day/game/game.tscn"
	GameManager.game_state['teleport_type'] = 'dream2day'
	get_tree().change_scene_to_file(transition_scene)
