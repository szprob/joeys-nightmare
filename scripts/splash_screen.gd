extends Node2D

@onready var sprite: Sprite2D = $CanvasLayer/Sprite2D
var fade_duration: float = 1.5
var display_time: float = 1.5
var timer: float = 0.0
var phase: int = 0 # 0: fade in, 1: display, 2: fade out

func _ready():
	# 初始化图片透明度为0
	sprite.modulate.a = 0.0

func _process(delta):
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
	get_tree().change_scene_to_file("res://scenes/start.tscn")
