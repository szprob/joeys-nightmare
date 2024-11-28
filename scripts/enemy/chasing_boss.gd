extends CharacterBody2D

@export var speed = 40
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 2.0
@export var player: Node2D

var time_since_last_shot: float = 0.0

func _ready():
	if !has_node("BulletContainer"):
		var container = Node2D.new()
		container.name = "BulletContainer"
		add_child(container)
	
	# 初试位置在玩家的左上方
	global_position = player.global_position + Vector2(-100, -100)


func _physics_process(delta: float) -> void:
	var distance = player.global_position.distance_to(global_position)
	if distance > 240:
		speed = (distance / 240) * 80 - 45
	elif distance > 120:
		speed = 35
	else:
		speed = 15
	
	# 计算朝向玩家的方向
	var direction = (player.global_position - global_position).normalized()
	
	# 设置速度并移动
	velocity = direction * speed
	move_and_slide()
	
	# 更新射击计时器
	time_since_last_shot += delta
	if time_since_last_shot >= shoot_interval:
		shoot()
		time_since_last_shot = 0.0

func shoot() -> void:
	return
	# var b = bullet_scene.instantiate()
	# # print('b', b)
	# # 将子弹添加到专门的容器中
	# get_tree().root.add_child(b)
	
	# var shoot_direction = (player.global_position - global_position).normalized()
	# # 设置子弹的全局位置为发射点的位置
	# b.start(global_position, shoot_direction)
