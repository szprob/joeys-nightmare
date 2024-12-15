extends CharacterBody2D

@export var bounce_force = 400 # 弹跳力度
@export var push_strength = 100
@export var mass = 3
var is_stomped = false

func _ready():
	add_to_group("pushable")
	add_to_group("bouncy") # 添加一个新的组来标识这是可弹跳的箱子

func _physics_process(delta):
	velocity += get_gravity() * delta / mass
	move_and_slide()


func stomp(impulse: Vector2, delta: float):
	is_stomped = true
	
	# 计算弹跳方向(与重力相反)
	var bounce_direction = -get_gravity().normalized()
	
	# 给玩家一个向上的弹跳速度
	velocity = bounce_direction * bounce_force
	
	move_and_slide()
	is_stomped = false

func push(direction: Vector2):
	velocity = direction * push_strength
	move_and_slide()
	velocity = Vector2.ZERO

func inelastic_collision(other_body: CharacterBody2D):
	# 获取两个物体的质量
	var m1 = self.mass
	var m2 = other_body.mass
	
	# 获取碰撞前的速度
	var v1 = self.velocity
	var v2 = other_body.velocity
	
	# 计算碰撞后的速度（完全非弹性碰撞）
	var final_velocity = (m1 * v1 + m2 * v2) / (m1 + m2)
	
	# 更新两个物体的速度
	self.velocity = final_velocity
	other_body.velocity = final_velocity
