extends Area2D

var gravity_scene = preload("res://scenes/sokoban/gravity_1.tscn")
var player_in_area = false
var player_position: Vector2

@export var new_gravity_direction: Vector2 = Vector2(0, -5)

func _ready() -> void:
	monitorable = true
	monitoring = true

	# 连接信号
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if player_in_area and Input.is_action_just_pressed("jump"):
		# 创建重力场景实例
		var gravity_instance = gravity_scene.instantiate()
		gravity_instance.position = position
		gravity_instance.scale = Vector2(2, 2)
		gravity_instance.gravity_direction = new_gravity_direction
		get_parent().add_child(gravity_instance)
		# 创建后销毁当前区域
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	print("body entered: ", body)
	if body.is_in_group("player"):
		print("player in area")
		player_in_area = true
		player_position = body.position

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
