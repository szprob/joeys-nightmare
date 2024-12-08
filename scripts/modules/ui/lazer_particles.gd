extends GPUParticles2D

func _ready():
	# 基础设置
	emitting = true      # 改为默认开启
	one_shot = false     # 改为持续发射
	explosiveness = 0.0  # 改为0以获得连续效果
	amount = 16          # 可以适当减少粒子数量
	lifetime = 0.1       # 稍微缩短生命周期使效果更加紧凑
	
	var particle_material = ParticleProcessMaterial.new()
	# 修改发射参数
	particle_material.direction = Vector3(0, 1, 0)    # 基准方向（实际上方向不重要，因为我们会使用360度散布）
	particle_material.spread = 180.0                  # 设置为180度，这样会覆盖整个圆
	particle_material.initial_velocity_min = 40.0     # 稍微降低速度使效果更好
	particle_material.initial_velocity_max = 80.0
	
	# 启用径向发射
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	particle_material.emission_sphere_radius = 1.0    # 小半径，让粒子从接近中心点发射

	
	# 火花颜色渐变
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 0.9, 0.3, 1.0))    # 明亮的黄色
	gradient.add_point(0.3, Color(1.0, 0.5, 0.0, 0.8))    # 橙色
	gradient.add_point(1.0, Color(1.0, 0.2, 0.0, 0))      # 淡红色渐隐
	
	
	var color_ramp = GradientTexture1D.new()
	color_ramp.gradient = gradient
	particle_material.color_ramp = color_ramp
	
	# 物理参数
	particle_material.gravity = Vector3(0, 200, 0)    # 减小重力影响
	particle_material.damping_min = 2.0               # 增加阻尼
	particle_material.damping_max = 4.0
	
	# 角度设置
	particle_material.angle_min = -180.0              # 允许粒子完全旋转
	particle_material.angle_max = 180.0
	
	process_material = particle_material
