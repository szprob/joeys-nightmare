extends CharacterBody2D

@onready var path_follow: PathFollow2D = get_parent()

@export var speed = 40
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 2.0
var time_since_last_shot: float = 0.0
var shoot_direction = Vector2(0, 1)
var moving_forward = true


func _ready() -> void:
	path_follow.progress = 0.0
	if !has_node("BulletContainer"):
		var container = Node2D.new()
		container.name = "BulletContainer"
		add_child(container)
		# print('container', container)

func _physics_process(delta: float) -> void:
	# 更新射击计时器
	time_since_last_shot += delta
	
	if time_since_last_shot >= shoot_interval:
		shoot()
		time_since_last_shot = 0.0

	# 根据移动方向确定速度正负
	var movement = speed * delta * (1 if moving_forward else -1)
	path_follow.progress += movement

	# 检查是否到达路径终点或起点
	if moving_forward and path_follow.progress_ratio >= 1.0:
		moving_forward = false
	elif !moving_forward and path_follow.progress_ratio <= 0.0:
		moving_forward = true


func shoot() -> void:
	var b = bullet_scene.instantiate()
	# print('b', b)
	# 将子弹添加到专门的容器中
	get_tree().root.add_child(b)
	# 设置子弹的全局位置为发射点的位置
	b.start(global_position, shoot_direction)
