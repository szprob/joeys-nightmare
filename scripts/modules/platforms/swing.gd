extends CharacterBody2D

@export var mass = 1  # 物体质量
@export var swing_amplitude = 10.0  # 初始摆动幅度(度)
@export var pivot_target: Area2D  # 枢轴点位置
@export var rope_color: Color = Color.WHEAT  # 绳子颜色
@export var rope_width: float = 2.0  # 绳子宽度
@export var speed_factor = 0.4  # 减速系数
@export var init_damping = 1  # 阻尼系数,控制摆动衰减速度
@export var player_force_factor = 500.0  # 玩家移动产生的力的系数

var damping = init_damping
var current_angle = 0.0
var angular_velocity = 0.0
var rope_length = 0.0  # 现在在_ready中自动计算
var player_on_swing = false  # 新增变量跟踪玩家是否在秋千上
var pivot_position : Vector2

func _ready():
	pivot_position = pivot_target.global_position
	
	# 根据初始位置计算绳长
	rope_length = global_position.distance_to(pivot_position)
	
	# 设置初始角度为最大摆动幅度
	current_angle = swing_amplitude
	
	# 根据摆动幅度计算所需的初始角速度
	# 使用简谐运动公式: v = sqrt(2gh)(1-cos(θ))
	# 其中 h 是最大高度变化,可以通过摆动幅度计算
	var max_height = rope_length * (1 - cos(deg_to_rad(swing_amplitude)))
	var gravity_strength = get_gravity().length()
	angular_velocity = sqrt(2 * gravity_strength * max_height) / rope_length


func _physics_process(delta):
	# 获取当前位置的重力
	var gravity_vec = get_gravity()
	var gravity_strength = gravity_vec.length()
	var _gravity_angle = gravity_vec.angle()
	
	# 修改角度因子计算
	var angle_rad = deg_to_rad(current_angle)
	var angle_factor = cos(angle_rad)
	
	# 计算目标位置
	var target_x = pivot_position.x + rope_length * sin(deg_to_rad(current_angle))
	var target_y = pivot_position.y + rope_length * cos(deg_to_rad(current_angle))
	var target_pos = Vector2(target_x, target_y)
	
	# 直接设置位置,而不是通过velocity移动
	global_position = target_pos
	
	# 其他物理计算保持不变
	damping = float(init_damping)
	
	var angle_abs = abs(current_angle)
	if angle_abs > 10.0:
		damping = 0.996
	
	var angular_acceleration = -gravity_strength * sin(angle_rad) / rope_length * speed_factor * angle_factor
	
	# 检测玩家的水平移动并添加额外的角加速度
	if get_child_count() > 0:
		var player = get_tree().get_nodes_in_group("player")[0]
		if player and player_on_swing:
			var player_movement = player.velocity.x
			if player_movement != 0:
				var swing_direction = sign(angular_velocity)
				var movement_direction = sign(player_movement)
				
				# 同样为玩家施加的力添加角度因子
				var direction_multiplier = 1.0
				if swing_direction == movement_direction:
					direction_multiplier = 3.0 * angle_factor  # 同向时也考虑角度因素
				else:
					direction_multiplier = 0.1
					damping = 0.97
				
				var player_force = movement_direction * player_force_factor * direction_multiplier
				var additional_angular_acc = player_force * cos(angle_rad) / rope_length
				angular_acceleration += additional_angular_acc

	# 更新角度和角速度
	angular_velocity = angular_velocity * damping + angular_acceleration * delta
	current_angle += rad_to_deg(angular_velocity) * delta
	
	# 使用更柔和的限制
	current_angle = clamp(current_angle, -89.0, 89.0)
	
	# 每次更新位置后重绘绳子
	queue_redraw()

func _draw():
	# 画出从枢轴点到座位的绳子
	var local_pivot = to_local(pivot_position)
	# 根据当前角度旋转绳子的绘制,而不是整个节点
	draw_line(
		local_pivot,
		Vector2.ZERO,
		rope_color,
		rope_width
	)


func _on_detection_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_on_swing = true


func _on_detection_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_on_swing = false
