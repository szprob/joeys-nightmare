extends CharacterBody2D

@onready var animated_sprites: Array[AnimatedSprite2D] = []
@onready var detection: Area2D = $detection

@export var mass = 1  # 物体质量
@export var pivot_target: Area2D  # 枢轴点位置
@export var rope_color: Color = Color.WHEAT  # 绳子颜色
@export var rope_width: float = 2.0  # 绳子宽度
@export var speed_factor = 0.4  # 减速系数
@export var init_damping = 1  # 阻尼系数,控制摆动衰减速度
@export var player_force_factor = 35.0  # 玩家移动产生的力的系数
@export var max_angular_velocity = 1.5  # 角速度上限
@export var min_swing_amplitude = 5.0  # 最小摆动幅度(度)

var damping = init_damping
var current_angle = 0.0
var angular_velocity = 0.0
var rope_length = 0.0  # 现在在_ready中自动计算
var player_on_swing = false  # 新增变量跟踪玩家是否在秋千上
var pivot_position : Vector2
var original_scale

func _ready():
	pivot_position = pivot_target.global_position

	# 获取检测区域节点
	detection.body_entered.connect(_on_detection_body_entered)
	detection.body_exited.connect(_on_detection_body_exited)
	# 在_ready中初始化精灵数组并设置偏移原点
	for i in range(1, 9):
		var sprite_name = "AnimatedSprite2D" if i == 1 else "AnimatedSprite2D" + str(i)
		var sprite = get_node(sprite_name)
		animated_sprites.append(sprite)
		
	# 根据初始位置计算绳长
	rope_length = global_position.distance_to(pivot_position)
	
	# 根据初始位置计算摆动幅度
	var initial_offset = global_position - pivot_position
	var vertical_down = Vector2(0, 1)  # 垂直向下的向量
	current_angle = rad_to_deg(initial_offset.angle_to(vertical_down))
	
	# 确保至少有最小摆动幅度
	if abs(current_angle) < min_swing_amplitude:
		current_angle = min_swing_amplitude * sign(current_angle)
		if current_angle == 0:  # 如果角度为0，默认向右摆动
			current_angle = min_swing_amplitude
	
	# 根据摆动幅度计算所需的初始角速度
	var max_height = rope_length * (1 - cos(deg_to_rad(current_angle)))
	var gravity_strength = get_gravity().length()
	angular_velocity = sqrt(2 * gravity_strength * max_height) / rope_length

	original_scale = animated_sprites[0].scale  # 获取精灵的当前缩放值

func animate_swing():
	# 计算火焰变形的基础参数
	var normalized_speed = clamp(angular_velocity / max_angular_velocity, -1.0, 1.0)
	
	for sprite in animated_sprites:
		# 增加旋转角度范围
		var rotation_angle = -normalized_speed * 45.0
		
		# 增加变形系数
		var deform_factor = abs(normalized_speed)
		var scale_x = original_scale.x * (1.0 - deform_factor * 0.5)
		var scale_y = original_scale.y * (1.0 + deform_factor * 0.6)
		
		# 应用变形和偏移，保持原始位置
		sprite.rotation_degrees = rotation_angle
		sprite.scale = Vector2(scale_x, scale_y)


func _physics_process(delta):
	animate_swing()
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
	
	# 将直接设置位置改为使用velocity和move_and_slide
	var desired_velocity = (target_pos - global_position) / delta
	
	# 计算最大线速度
	var max_linear_velocity = rad_to_deg(max_angular_velocity) * rope_length
	
	# 限制desired_velocity的长度
	if desired_velocity.length() > max_linear_velocity:
		desired_velocity = desired_velocity.normalized() * max_linear_velocity
	
	# 使用global_position直接更新位置
	global_position += desired_velocity * delta
	
	# 更新rope_length以保持绳子长度不变
	var current_length = global_position.distance_to(pivot_position)
	if current_length != rope_length:
		var correction = (pivot_position - global_position).normalized() * (current_length - rope_length)
		global_position += correction

	# 其他物理计算保持不变
	damping = float(init_damping)
	
	var angle_abs = abs(current_angle)
	if angle_abs > 10.0:
		if player_on_swing:
			damping = 0.996
		else:
			damping = 1 
	
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
	
	# 给角速度一个上限
	angular_velocity = clamp(angular_velocity, -max_angular_velocity, max_angular_velocity)
	
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
