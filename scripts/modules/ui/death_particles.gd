extends GPUParticles2D

func _ready():
	# 基础设置
	emitting = false
	one_shot = true
	explosiveness = 1.0
	amount = 64
	lifetime = 0.8
	
	var particle_material = ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0, -1, 0)
	particle_material.spread = 180.0
	particle_material.initial_velocity_min = 150.0
	particle_material.initial_velocity_max = 250.0
	particle_material.scale_min = 2.0
	particle_material.scale_max = 4.0
	
	# 血液颜色渐变
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0.8, 0.0, 0.0, 1.0))
	gradient.add_point(0.6, Color(0.6, 0.0, 0.0, 0.8))
	gradient.add_point(1.0, Color(0.4, 0.0, 0.0, 0))
	
	var color_ramp = GradientTexture1D.new()
	color_ramp.gradient = gradient
	particle_material.color_ramp = color_ramp
	
	# 物理参数
	particle_material.gravity = Vector3(0, 980, 0)
	particle_material.damping_min = 0.5
	particle_material.damping_max = 1.0
	
	# 角度设置
	particle_material.angle_min = -45.0
	particle_material.angle_max = 45.0
	
	process_material = particle_material
