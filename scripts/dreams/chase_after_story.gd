extends Node2D

@export var player: Node2D # 玩家节点
@export var npc: Node2D # NPC节点
# @export var subtitle_label: Label # 字幕标签
@export var camera: Camera2D
@export var subtitle_container: Control
@export var subtitle_label: Label
@export var camera_path: Path2D
@export var title: Sprite2D

var camera_pan_started = false


var subtitles = [
	{"time": 0, "text": "A* studio presents"},
	{"time": 4, "text": "Team members"},
	{"time": 6, "text": "Producer and Level Design \n Zhao Hougang"},
	{"time": 10, "text": "Programming \n Song ze  Pan Ziyi"},
	{"time": 14, "text": "Art \n Cao Xiao  Tang Chenwei"},
	{"time": 18, "text": "Day Levels \n Huang Yuchen"},
	{"time": 24, "text": "Special Thanks \n Friends and Family of GI Team"},
	{"time": 28, "text": ""}
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
	if title:
		title.visible = false
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
	
	# 场景结束条件（例如：10秒后） 26
	if scene_timer >= 26.0 and not camera_pan_started:
		start_camera_pan()
		camera_pan_started = true
		# end_scene()
	if scene_timer >= 32.0 and title:
		title.visible = true

func end_scene():
	player.stop_auto_run()
	if npc.has_method("stop_auto_run"):
		npc.stop_auto_run()
	# 这里可以切换到下一个场景或触发其他事件
	GameManager.game_state['target_scene'] = "res://scenes/day/game/game.tscn"
	GameManager.game_state['teleport_type'] = 'dream2day'
	get_tree().change_scene_to_file("res://scenes/modules/checkpoints/transition.tscn")

func start_camera_pan():
	print('camera start pos: ', camera.global_position)
	print("start_camera_pan")
	var tween = create_tween()
	var path_follow = PathFollow2D.new()
	camera_path.add_child(path_follow)
	

	# 1. 先记录相机当前的全局位置
	var current_camera_pos = camera.global_position
	
	# 2. 从原父节点移除相机
	var path_start_point = camera_path.curve.get_point_position(0)
	
	# 3. 将相机添加到 path_follow（只添加一次）
	
	path_start_point = camera_path.to_global(path_start_point)
	path_follow.loop = false
	path_follow.rotates = true
	var original_parent = camera.get_parent()
	original_parent.remove_child(camera)
	path_follow.add_child(camera)
	camera.global_position = current_camera_pos
	# camera.position = current_camera_pos
	
	# 4. 设置 PathFollow2D 的初始位置
	# 将 path_follow 移动到路径上最接近相机当前位置的点
	# var closest_point = camera_path.curve.get_closest_point(current_camera_pos)
	# var closest_offset = camera_path.curve.get_closest_offset(current_camera_pos)
	# path_follow.progress = closest_offset
	

	# 5. 调整相机相对于 path_follow 的位置
	# camera.position = Vector2.ZERO # 或者使用小的偏移，如果需要的话
	
	# 6. 设置 PathFollow2D 的属性
	
	
	# tween.tween_property(camera, 'global_position', path_start_point, 5.0).from(current_camera_pos) \
	tween.tween_property(camera, 'global_position', path_start_point, 1.0) \
	.set_ease(Tween.EASE_IN_OUT) \
	.set_trans(Tween.TRANS_CUBIC)

	
	# 7. 开始动画
	tween.tween_property(path_follow, "progress_ratio", 1.0, 5.0).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(2.0)
	tween.tween_callback(end_scene)
