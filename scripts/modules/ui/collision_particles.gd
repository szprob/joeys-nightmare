extends GPUParticles2D

func _ready():
	# 基础设置
	emitting = false
	one_shot = true
	explosiveness = 0.8  # 让粒子更平滑地扩散
	amount = 128  # 增加粒子数量
	lifetime = 1.2  # 增加粒子寿命
	
	var particle_material = ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0, 0, 0)  # 向四周扩散
	particle_material.spread = 360.0  # 全方向扩散
	particle_material.initial_velocity_min = 200.0  # 增加速度
	particle_material.initial_velocity_max = 400.0
	particle_material.scale_min = 1.0  # 调整粒子大小
	particle_material.scale_max = 3.0
	
	# 颜色渐变
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 0.8, 0.0, 1.0))  # 使用更亮的颜色
	gradient.add_point(0.5, Color(1.0, 0.5, 0.0, 0.8))
	gradient.add_point(1.0, Color(1.0, 0.2, 0.0, 0))
	
	var color_ramp = GradientTexture1D.new()
	color_ramp.gradient = gradient
	particle_material.color_ramp = color_ramp
	
	# 物理参数
	particle_material.gravity = Vector3(0, 500, 0)  # 减小重力影响
	particle_material.damping_min = 0.3  # 增加随机性
	particle_material.damping_max = 0.7
	
	# 角度设置
	particle_material.angle_min = -90.0
	particle_material.angle_max = 90.0
	
	process_material = particle_material
