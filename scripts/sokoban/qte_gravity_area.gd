extends Area2D

@export var is_draw: bool = true

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

	if is_draw:
		queue_redraw()

func _draw() -> void:
	if not is_draw:
		return
		
	var collision_shape = get_node("CollisionShape2D")
	if not collision_shape:
		return
		
	var radius: float
	if collision_shape.shape is CircleShape2D:
		radius = collision_shape.shape.radius
	elif collision_shape.shape is RectangleShape2D:
		var shape_size = collision_shape.shape.size
		radius = min(shape_size.x, shape_size.y) / 2
	else:
		return
	
	# 绘制圆形
	draw_circle(Vector2.ZERO, radius, Color(0.5, 0.8, 1.0, 0.7))
	draw_arc(Vector2.ZERO, radius, 0, PI * 2, 32, Color(1, 1, 1, 0.5), 2.0)
	
	# 绘制箭头
	var arrow_length = radius * 1.6
	var arrow_direction = new_gravity_direction.normalized()
	var arrow_point = arrow_direction * (arrow_length / 2)
	var arrow_start = -arrow_direction * (arrow_length / 2)
	var arrow_width = radius * 0.2
	
	# 绘制箭头主体
	draw_line(arrow_start, arrow_point, Color(1, 1, 1, 0.8), 2.0)
	
	# 绘制箭头头部
	var angle = new_gravity_direction.angle()
	var left_point = arrow_point + Vector2(arrow_width, 0).rotated(angle + PI * 0.75)
	var right_point = arrow_point + Vector2(arrow_width, 0).rotated(angle - PI * 0.75)
	
	var points = PackedVector2Array([arrow_point, left_point, right_point])
	draw_colored_polygon(points, Color(1, 1, 1, 0.8))

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
