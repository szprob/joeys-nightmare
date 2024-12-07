extends AnimatableBody2D

@export var rotation_angular_velocity: float = 5.0
@export var clockwise: bool = true
@export var initial_rotation: float = 0.0

var animated_bodies: Array[AnimatableBody2D] = []

var original_scale
var random_start_frame: int = 0

func _ready():
	rotation = initial_rotation
	
	# 获取所有的AnimatableBody2D并放入列表
	for child in get_children():
		if child is AnimatableBody2D:
			animated_bodies.append(child)

	original_scale = animated_bodies[0].get_node("AnimatedSprite2D").scale
	var total_frames = animated_bodies[0].get_node("AnimatedSprite2D").sprite_frames.get_frame_count(animated_bodies[0].get_node("AnimatedSprite2D").animation)
	for b in animated_bodies:
		random_start_frame = randi() % total_frames
		b.get_node("AnimatedSprite2D").frame = random_start_frame
		b.get_node("AnimatedSprite2D").play()

func animate_fire():
	# 计算火焰变形的基础参数
	var normalized_speed = clamp(rotation_angular_velocity / 5, -1.0, 1.0)
	
	for b in animated_bodies:
		var sprite = b.get_node("AnimatedSprite2D")
		
		# 使用global_position计算到中心点的实际世界距离
		var distance_to_center = (b.global_position - global_position).length()
		# 根据距离调整变形系数，距离越远变形越大
		var distance_factor = distance_to_center / 70.0  # 可以调整除数来控制影响程度
		
		# 增加旋转角度范围
		var rotation_angle = -normalized_speed * 45.0 * (1.0 + distance_factor * 0.5)
		
		# 根据当前实际旋转方向动态更新flip_h
		sprite.flip_v = false if clockwise else true
		sprite.flip_h = true if clockwise else false

		# 使用距离因子调整变形效果
		var deform_factor = abs(normalized_speed) * (1.0 + distance_factor) / 3
		var scale_x = original_scale.x * (1.0 - deform_factor * 0.5)
		var scale_y = original_scale.y * (1.0 + deform_factor * 0.6)
		
		# 应用变形和偏移，保持原始位置
		sprite.rotation_degrees = rotation + rotation_angle
		sprite.scale = Vector2(scale_x, scale_y)


func _physics_process(delta):
	var rotation_direction = 1 if clockwise else -1
	rotation += rotation_angular_velocity * delta * rotation_direction
	animate_fire()
