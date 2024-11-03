extends Node2D

@onready var sprite: Sprite2D = $CanvasLayer/Sprite2D3
@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var fade_duration: float = 2.5
var display_time: float = 2.5
var timer: float = 0.0
var phase: int = 0 # 0: fade in, 1: display, 2: fade out
var audio_timer: float = 0.0  # 新增音频计时器

func _ready():
	# 初始化图片透明度为0
	sprite.modulate.a = 0.0
	if sfx_player:
		sfx_player.play()

func _process(delta):
	# 新增音频计时逻辑
	if sfx_player and sfx_player.playing:
		audio_timer += delta
		if audio_timer >= 7.0:  # 7秒后停止播放
			sfx_player.stop()
	
	match phase:
		0:
			# 渐入阶段
			timer += delta
			sprite.modulate.a = clamp(timer / fade_duration, 0.0, 1.0)
			if timer >= fade_duration:
				phase = 1
				timer = 0.0
		1:
			# 显示阶段
			timer += delta
			if timer >= display_time:
				phase = 2
				timer = 0.0
		2:
			# 渐出阶段
			timer += delta
			sprite.modulate.a = clamp(1.0 - (timer / fade_duration), 0.0, 1.0)
			if timer >= fade_duration:
				go_to_main_menu()

func go_to_main_menu():
	# 切换到主菜单场景
	get_tree().change_scene_to_file("res://scenes/main/start.tscn")
