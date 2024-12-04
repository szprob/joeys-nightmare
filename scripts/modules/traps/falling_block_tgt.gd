extends Area2D

@export var speed: float = Consts.FALLING_TRAP_SPEED  # 可配置的速度
@export var invisible_before_launch :bool = true  # 添加是否隐身的配置
@export var target: Area2D
@export var detection: Area2D
@export var idle_shake_strength: float = 5.0    # 普通抖动强度
@export var alert_shake_strength: float = 8.0   # 触发后的抖动强度
@export var shake_duration: float = 0.2
@export var alert_duration: float = 1.2         # 触发后的剧烈抖动持续时间

var is_flying_forward: bool = false
var fly_direction: Vector2 = Vector2.ZERO
var init_position: Vector2 = Vector2.ZERO
var final_position : Vector2 = Vector2.ZERO
var do_detect = true 
var original_pos: Vector2
var tween: Tween
var is_alerted: bool = false

@onready var falling_trap: Area2D = $"."
@onready var timer: Timer = $Timer

func _ready() -> void:
	init_position = global_position
	final_position = target.global_position
	original_pos = position
	if invisible_before_launch:
		modulate.a = 0
	detection.body_entered.connect(_on_detection_body_entered)
	
	# 开始持续的闲置抖动
	start_idle_shake()

func _physics_process(delta):
	if is_flying_forward:
		global_position += fly_direction * speed * delta
		if global_position.distance_to(final_position) < 5:
			global_position = final_position
			is_flying_forward = false
			GameManager.camera_shake_requested.emit(30.0, 0.2)
			timer.start()

func _on_timer_timeout() -> void:
	# Reset trap position and states
	reset_trap()

func reset_trap() -> void:
	# Create a tween for smooth return movement
	var return_tween = create_tween()
	return_tween.tween_property(
		self,
		"global_position",
		init_position,
		1.0  # 返回时间为1秒，可以根据需要调整
	).set_ease(Tween.EASE_IN_OUT)
	
	# Reset other states after return animation completes
	return_tween.finished.connect(func():
		do_detect = true
		is_alerted = false
		if invisible_before_launch:
			modulate.a = 0
		start_idle_shake()
	)

# 添加新的检测函数
func _on_detection_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and do_detect:
		print("Detection triggered")
		do_detect = false
		is_alerted = true
		if invisible_before_launch:
			modulate.a = 1
		start_alert_shake()

# 添加抖动函数
func start_idle_shake() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween().set_loops()  # 设置循环
	original_pos = position
	
	# 创建一个简单的来回抖动
	for i in range(2):
		var shake_offset = Vector2(
			randf_range(-idle_shake_strength, idle_shake_strength),
			randf_range(-idle_shake_strength, idle_shake_strength)
		)
		
		var target_pos = original_pos if i % 2 == 0 else original_pos + shake_offset
		tween.tween_property(
			self,
			"position",
			target_pos,
			shake_duration
		).set_ease(Tween.EASE_IN_OUT)

func start_alert_shake() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.finished.connect(_on_alert_shake_finished)
	
	for i in range(10):  # 更多的抖动次数
		var shake_offset = Vector2(
			randf_range(-alert_shake_strength, alert_shake_strength),
			randf_range(-alert_shake_strength, alert_shake_strength)
		)
		
		var target_pos = original_pos if i % 2 == 0 else original_pos + shake_offset
		tween.tween_property(
			self,
			"position",
			target_pos,
			alert_duration / 10
		).set_ease(Tween.EASE_IN_OUT)
	
	# 最后回到原位
	tween.tween_property(self, "position", original_pos, 0.1)

func _on_alert_shake_finished() -> void:
	print("Alert shake finished, starting timer")
	is_flying_forward = true
	if invisible_before_launch:
		modulate.a = 1  # 发射时显示
	fly_direction = (final_position  - global_position).normalized()
