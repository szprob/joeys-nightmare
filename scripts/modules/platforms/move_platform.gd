extends AnimatableBody2D

enum MoveType { ONE_WAY, LOOP }  # 移动类型：单程或往返

@export var move_type: MoveType = MoveType.ONE_WAY  # 导出变量允许在编辑器中设置
@export var wait_time: float = 1.0  # 到达终点后等待时间
@export var do_detect: bool = false  # 是否需要玩家触发才移动
@export var move_speed: float = Consts.MOVE_PLATFORM_SPEED
@export var initial_delay: float = 0.5  # 添加初始等待时间设置
@export var invisible_before_trigger: bool = false  # 添加是否在触发前隐身的选项
@export var target: Area2D

var is_moving: bool = false
var move_direction: Vector2 = Vector2.ZERO
var final_position: Vector2 = Vector2.ZERO
var start_position: Vector2
var moving_to_target: bool = true  # 用于往返移动


@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = Timer.new() #启动时间
@onready var start_timer: Timer = Timer.new() #初始等待时间

func _ready() -> void:
	if not target:
		push_error("移动平台缺少目标点!")
		return
		
	start_position = global_position
	final_position = target.global_position
	move_direction = (target.global_position - global_position).normalized()
	
	# 如果设置为触发前隐身,则初始化时隐藏平台
	if invisible_before_trigger:
		modulate.a = 0.0
	
	# 设置等待计时器
	add_child(timer)
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

	# 设置初始等待计时器
	start_timer = Timer.new()
	add_child(start_timer)
	start_timer.one_shot = true
	start_timer.wait_time = initial_delay
	start_timer.timeout.connect(_on_start_timer_timeout)

	# 如果不需要检测玩家触发，则直接开始移动
	if not do_detect:
		start_timer.start()

func _physics_process(delta: float) -> void:
	if not is_moving:
		return
		
	var target_pos = final_position if moving_to_target else start_position
	global_position += move_direction * move_speed * delta
	
	if global_position.distance_to(target_pos) < 3:
		global_position = target_pos
		handle_destination_reached()

func handle_destination_reached() -> void:
	is_moving = false
	
	match move_type:
		MoveType.ONE_WAY:
			pass  # 单程移动,到达后就停止
		MoveType.LOOP:
			# 开始等待
			timer.start()

func _on_timer_timeout() -> void:
	if move_type == MoveType.LOOP:
		# 改变方向
		moving_to_target = !moving_to_target
		move_direction = -move_direction
		is_moving = true

func _on_detection_body_entered(body: Node2D) -> void:
	if not do_detect:
		return
		
	if body is CharacterBody2D and body.global_position.y < global_position.y:
		if invisible_before_trigger:
			# 显示平台
			modulate.a = 1.0
		start_timer.start()  # 启动初始等待计时器而不是直接移动

func _on_start_timer_timeout() -> void:
	is_moving = true
