extends Area2D

@export var rotation_speed: float = 1.0
@export var max_rotation: float = 30.0

var current_rotation: float = 0.0
var left_weight: float = 0.0
var right_weight: float = 0.0

@onready var rod: StaticBody2D = $rod
@onready var left_side: Area2D = $left_side
@onready var right_side: Area2D = $right_side
@onready var left_plate: StaticBody2D = $left_plate
@onready var right_plate: StaticBody2D = $right_plate
@onready var fulcrum: StaticBody2D = $fulcrum

# 添加新的变量来存储初始位置
var initial_left_side_offset: Vector2
var initial_right_side_offset: Vector2
var initial_left_plate_offset: Vector2
var initial_right_plate_offset: Vector2

func _ready() -> void:
	current_rotation = rotation_degrees
	# 保存所有组件相对于支点的初始偏移量
	var pivot = fulcrum.global_position
	initial_left_side_offset = left_side.global_position - pivot
	initial_right_side_offset = right_side.global_position - pivot
	initial_left_plate_offset = left_plate.global_position - pivot
	initial_right_plate_offset = right_plate.global_position - pivot
	
	left_side.body_entered.connect(_on_left_side_body_entered)
	left_side.body_exited.connect(_on_left_side_body_exited)
	right_side.body_entered.connect(_on_right_side_body_entered)
	right_side.body_exited.connect(_on_right_side_body_exited)



func _physics_process(delta: float) -> void:
	# 增加权重差异的影响
	var weight_difference = right_weight - left_weight
	var target_rotation = sign(weight_difference) * max_rotation
	
	# 使用 smoothstep 来实现更平滑的过渡
	current_rotation = lerp(
		current_rotation,
		target_rotation,
		rotation_speed * delta * 0.4
	)
	# 只更新 rod 的旋转角度
	rod.rotation_degrees = current_rotation

	# 获取支点位置
	var pivot = fulcrum.global_position
	
	# 计算旋转角度（弧度）
	var rotation_rad = deg_to_rad(current_rotation)
	
	# 使用初始偏移量来计算新位置
	left_side.global_position = pivot + initial_left_side_offset.rotated(rotation_rad)
	right_side.global_position = pivot + initial_right_side_offset.rotated(rotation_rad)
	left_plate.global_position = pivot + initial_left_plate_offset.rotated(rotation_rad)
	right_plate.global_position = pivot + initial_right_plate_offset.rotated(rotation_rad)




func _on_left_side_body_entered(body: CharacterBody2D) -> void:
	if "mass" in body:
		left_weight += body.mass

func _on_left_side_body_exited(body: CharacterBody2D) -> void:
	if 'mass' in body:
		left_weight -= body.mass

func _on_right_side_body_entered(body: CharacterBody2D) -> void:
	if "mass" in body:
		right_weight += body.mass

func _on_right_side_body_exited(body: CharacterBody2D) -> void:
	if 'mass' in body:
		right_weight -= body.mass
