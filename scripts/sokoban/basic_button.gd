extends Area2D

@export var doors: Array[NodePath]

var active_bodies: int = 0
# 使用字典跟踪已经在按钮上的物体
var tracked_bodies: Dictionary = {}

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# 添加音频衰减相关变量
@export var max_hearing_distance: float = 200.0  # 最大听觉距离
var player: Node2D = null  # 用于存储玩家引用

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	# 获取玩家引用
	player = get_tree().get_first_node_in_group("player")

func _on_body_entered(body):
	# 检查是否是玩家或箱子，且还未被记录
	if (body is CharacterBody2D or body.is_in_group("box")) and not tracked_bodies.has(body):
		tracked_bodies[body] = true
		active_bodies += 1
		# 播放按钮按下的音效
		if audio_player:
			audio_player.play()
		if active_bodies >= 1:
			print('Button activated, open the doors')
			$AnimatedSprite2D.frame = 1
			for door_path in doors:
				if door_path:
					get_node(door_path).open()
		
func _on_body_exited(body):
	# 检查是否是已记录的玩家或箱子
	if tracked_bodies.has(body):
		tracked_bodies.erase(body)
		active_bodies -= 1
		if active_bodies <= 0:
			active_bodies = 0
			print('All bodies exited, close the doors')
			$AnimatedSprite2D.frame = 0
			for door_path in doors:
				if door_path:
					get_node(door_path).close()

# 添加新函数来更新音量
func _process(_delta: float) -> void:
	if player and audio_player:
		var distance = global_position.distance_to(player.global_position)
		# 线性衰减，最大音量1.5倍（3.5 dB），最小值 -80dB
		var attenuation = 2 * (1.0 - clamp(distance / max_hearing_distance, 0.0, 1.0))
		var volume_db = linear_to_db(attenuation)
		audio_player.volume_db = float(volume_db if volume_db > -80.0 else -80.0)
