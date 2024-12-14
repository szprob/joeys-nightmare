extends Area2D

var has_been_activated = false  # 新增变量，用于记录是否已经激活过

@export var saved_time = 3.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var saved_label: Label = $Label
@onready var saved_timer: Timer
@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# 在_ready中添加Label节点
func _ready() -> void:
	# 创建保存提示文本
	saved_label.visible = false
	# 创建计时器
	saved_timer = Timer.new()
	saved_timer.one_shot = true
	saved_timer.wait_time = saved_time
	add_child(saved_timer)
	saved_timer.timeout.connect(_on_saved_timer_timeout)
	animated_sprite_2d.play("close")


func _on_body_entered(body: CharacterBody2D) -> void:
	if has_been_activated:
		return

	if body.is_in_group("player"):
		if sfx_player:
			sfx_player.play()
		has_been_activated = true
		animated_sprite_2d.play("open")
		var current_scene_path = get_tree().current_scene.scene_file_path
		GameManager.game_state['last_scene_path'] = current_scene_path
		GameManager.game_state['current_respawn_point_x'] = global_position.x
		GameManager.game_state['current_respawn_point_y'] = global_position.y
		GameManager.game_state['respawn_enable'] = true
		GameManager.save_game_state()
		
		# 重置并显示标签
		saved_label.modulate.a = 1.0  # 重置透明度
		saved_label.visible = true
		saved_timer.start()



func _on_saved_timer_timeout() -> void:
	saved_label.visible = false
	# has_been_activated = false
	# animated_sprite_2d.frame = 0
