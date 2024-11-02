extends Node2D


var target_scene: String
var teleport_type: String
var next_scene_resource: Resource

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	# 确保动画播放器已经准备好
	await ready
	
	teleport_type = GameManager.game_state['teleport_type']
	target_scene = GameManager.game_state['target_scene']
	print(teleport_type)
	print(target_scene)
	# # 设置动画位置在视口中心
	# var viewport_size = get_viewport_rect().size
	# # position = viewport_size / 2
	# # 或者直接设置 AnimatedSprite2D 的位置
	# animated_sprite_2d.global_position = viewport_size / 2
	# 获取视口大小
	var viewport_size = get_viewport_rect().size
	
	# 将动画精灵设置在视口中心
	animated_sprite_2d.position = viewport_size / 2
	
	# 根据视口大小调整动画精灵的缩放比例
	var sprite_size = animated_sprite_2d.sprite_frames.get_frame_texture(animated_sprite_2d.animation, 0).get_size()
	var scale_x = viewport_size.x / sprite_size.x
	var scale_y = viewport_size.y / sprite_size.y
	var scale_factor = max(scale_x, scale_y)  # 取最大值以确保完全覆盖
	animated_sprite_2d.scale = Vector2(scale_factor, scale_factor)
	# 设置动画不循环
	if teleport_type == 'day2dream':
		animated_sprite_2d.sprite_frames.set_animation_loop("day2dream", false)
		animated_sprite_2d.play("day2dream")
	elif teleport_type == 'dream2day':
		animated_sprite_2d.sprite_frames.set_animation_loop("dream2day", false)
		animated_sprite_2d.play("dream2day")
	elif teleport_type == 'dream2dream':
		animated_sprite_2d.sprite_frames.set_animation_loop("dream2dream", false)
		animated_sprite_2d.play("dream2dream")
	
	# 等待动画播放完成后切换场景
	await animated_sprite_2d.animation_finished
	get_tree().change_scene_to_file(target_scene)
