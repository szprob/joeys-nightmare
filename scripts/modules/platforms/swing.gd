extends CharacterBody2D

@export var mass = 1  # 物体质量
@export var swing_amplitude = 10.0  # 初始摆动幅度(度)
@export var max_swing_amplitude = 50.0  # 最大摆动幅度(度)
@export var pivot_position: Vector2  # 枢轴点位置
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

func _ready():
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
	
	var angular_acceleration = -gravity_strength * sin(deg_to_rad(current_angle)) / rope_length * speed_factor
	damping = init_damping
	# 检测玩家的水平移动并添加额外的角加速度
	if get_child_count() > 0:
		var player = get_tree().get_nodes_in_group("player")[0]
		if player and player_on_swing:  # 只在玩家在秋千上时计算
			var player_movement = player.velocity.x
			if player_movement != 0:
				# 根据秋千当前运动方向调整力度
				var swing_direction = sign(angular_velocity)
				var movement_direction = sign(player_movement)
				
				# 根据方向调整力度倍数
				var direction_multiplier = 1.0
				if swing_direction == movement_direction:
					direction_multiplier = 3.0  # 同向时增强
				else:
					direction_multiplier = 0.1  # 反向时减弱
					damping = 0.95
				
				var player_force = movement_direction * player_force_factor * direction_multiplier
				var additional_angular_acc = player_force * cos(deg_to_rad(current_angle)) / rope_length
				angular_acceleration += additional_angular_acc

	angular_velocity += angular_acceleration * delta
	
	# 增加阻尼系数使运动更自然
	angular_velocity *= damping
	
	# 更新角度
	current_angle += rad_to_deg(angular_velocity) * delta
	
	# 限制最大摆动幅度
	current_angle = clamp(current_angle, -max_swing_amplitude, max_swing_amplitude)
	
	# 如果达到最大摆动幅度，减小角速度以防止突然的反弹
	if abs(current_angle) >= max_swing_amplitude:
		angular_velocity *= 0.5
	
	# 首先计算目标位置
	var target_x = pivot_position.x + rope_length * sin(deg_to_rad(current_angle))
	var target_y = pivot_position.y + rope_length * cos(deg_to_rad(current_angle))
	var target_pos = Vector2(target_x, target_y)
	
	# 计算所需的速度
	velocity = (target_pos - global_position) / delta
	
	# 应用移动
	move_and_slide()
	
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
