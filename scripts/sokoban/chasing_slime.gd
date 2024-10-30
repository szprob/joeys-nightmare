extends CharacterBody2D

@export var pause_points: Array[float] = [] # 在路径上的暂停点（0-1之间的值）
@export var pause_duration: float = 1.0
@export var speed = 40
@onready var path_follow: PathFollow2D = get_parent()

var is_paused: bool = false
var pause_timer: float = 0.0
var moving_forward: bool = true

func _ready() -> void:
	path_follow.progress = 0.0

func _physics_process(delta: float) -> void:
	var path_length = path_follow.get_parent().curve.get_baked_length()
	
	#if not path_follow.loop:
		## 在端点处改变方向
		#if path_follow.progress_ratio >= 1.0:
			#moving_forward = false
		#elif path_follow.progress_ratio <= 0.0:
			#moving_forward = true
	#
	var movement = speed * delta

		
	path_follow.progress += movement
		
	# 检查是否到达暂停点
	#var unit_offset = path_follow.progress_ratio
	#for point in pause_points:
		#if abs(unit_offset - point) < 0.01:
			#is_paused = true
			#return
			
	# 正常移动逻辑
	path_follow.progress += speed * delta
