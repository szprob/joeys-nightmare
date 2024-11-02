extends Node2D

enum TeleportType {DAY2DREAM,DREAM2DAY} 



var next_scene_path: String
var teleport_type: TeleportType = TeleportType.DREAM2DAY
var next_scene_resource: Resource

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	# 确保动画播放器已经准备好
	await ready
	
	# 设置动画位置在视口中心
	var viewport_size = get_viewport_rect().size
	# position = viewport_size / 2
	# 或者直接设置 AnimatedSprite2D 的位置
	animated_sprite_2d.global_position = viewport_size / 2
	
	# 设置动画不循环
	if teleport_type == TeleportType.DAY2DREAM:
		animated_sprite_2d.sprite_frames.set_animation_loop("day2dream", false)
		animated_sprite_2d.play("day2dream")
	else:
		animated_sprite_2d.sprite_frames.set_animation_loop("dream2day", false)
		animated_sprite_2d.play("dream2day")
	# 在动画播放的同时开始加载下一个场景
	ResourceLoader.load_threaded_request(next_scene_path)

func _process(_delta):
	# 检查场景加载状态
	var load_status = ResourceLoader.load_threaded_get_status(next_scene_path)
	
	match load_status:
		ResourceLoader.THREAD_LOAD_LOADED:
			# 场景加载完成
			next_scene_resource = ResourceLoader.load_threaded_get(next_scene_path)
			# 等待淡出动画完成
			await animated_sprite_2d.animation_finished
			# 实例化并切换到新场景
			var next_scene = next_scene_resource.instantiate()
			get_tree().root.add_child(next_scene)
			# 移除过渡场景
			queue_free()
			
		ResourceLoader.THREAD_LOAD_FAILED:
			push_error("场景加载失败: " + next_scene_path)
			# 处理加载失败的情况
