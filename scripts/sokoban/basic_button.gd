extends Area2D

@export var doors: Array[NodePath]

var active_bodies: int = 0
# 使用字典跟踪已经在按钮上的物体
var tracked_bodies: Dictionary = {}

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
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
