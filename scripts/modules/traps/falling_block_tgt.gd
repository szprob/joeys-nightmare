extends Area2D

@export var speed: float = Consts.FALLING_TRAP_SPEED  # 可配置的速度
@export var invisible_before_launch :bool = true  # 添加是否隐身的配置
@export var target: Area2D
@export var detection: Area2D
@export var idle_shake_strength: float = 5.0    # 普通抖动强度
@export var alert_shake_strength: float = 8.0   # 触发后的抖动强度
@export var shake_duration: float = 0.2
@export var alert_duration: float = 1.2         # 触发后的剧烈抖动持续时间
@export var should_reset: bool = true  # Add reset control option
@export var initial_speed: float = 100.0  # Initial falling speed
@export var acceleration: float = 200.0   # Acceleration rate
@export var auto_trigger: bool = false
@export var trigger_interval: float = 3.0  # Time between auto triggers
@export var initial_delay: float = 0.0     # Delay before first trigger
@export var reset_delay: float = 1.0  # Time before trap resets
@export var can_destroy: bool = true

var is_flying_forward: bool = false
var fly_direction: Vector2 = Vector2.ZERO
var init_position: Vector2 = Vector2.ZERO
var final_position : Vector2 = Vector2.ZERO
var do_detect = true 
var original_pos: Vector2
var tween: Tween
var is_alerted: bool = false
var current_speed: float = 0.0            # Current speed that will change over time
var audio_player = null

@onready var falling_trap: Area2D = $"."
@onready var timer: Timer = $Timer
@onready var auto_trigger_timer: Timer = $AutoTriggerTimer

func _ready() -> void:
	init_position = global_position
	final_position = target.global_position
	original_pos = position
	if invisible_before_launch:
		modulate.a = 0
	detection.body_entered.connect(_on_detection_body_entered)
	current_speed = initial_speed  # Initialize current_speed
	
	for child in get_children():
		if child is AudioStreamPlayer2D:
			audio_player = child

	# 开始持续的闲置抖动
	start_idle_shake()
	
	# Setup auto trigger timer
	if auto_trigger:
		if not has_node("AutoTriggerTimer"):
			var timer = Timer.new()
			timer.name = "AutoTriggerTimer"
			add_child(timer)
			auto_trigger_timer = timer
		
		auto_trigger_timer.wait_time = trigger_interval
		auto_trigger_timer.timeout.connect(_on_auto_trigger_timeout)
		
		# Start with initial delay if specified
		if initial_delay > 0:
			auto_trigger_timer.start(initial_delay)
		else:
			auto_trigger_timer.start()
	timer.wait_time = reset_delay  # Set the reset timer wait time

func _physics_process(delta):
	if is_flying_forward:
		# Apply acceleration to current_speed
		current_speed += acceleration * delta
		
		# Move with current_speed instead of constant speed
		global_position += fly_direction * current_speed * delta
		
		if global_position.distance_to(final_position) < 5:
			if audio_player:
				audio_player.play(0.5)
			global_position = final_position
			is_flying_forward = false
			GameManager.camera_shake_requested.emit(30.0, 0.2)
			timer.start()

func _on_timer_timeout() -> void:
	if should_reset:
		reset_trap()

func reset_trap() -> void:
	# Create a tween for smooth return movement
	var return_tween = create_tween()
	return_tween.tween_property(
		self,
		"global_position",
		init_position,
		1.0
	).set_ease(Tween.EASE_IN_OUT)
	
	# Reset other states after return animation completes
	return_tween.finished.connect(func():
		do_detect = should_reset
		is_alerted = false
		current_speed = initial_speed  # Reset speed when trap resets
		if invisible_before_launch:
			modulate.a = 0
		if should_reset:
			start_idle_shake()
			# Restart auto trigger timer if enabled
			if auto_trigger:
				auto_trigger_timer.start()
	)

# 添加新的检测函数
func _on_detection_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and do_detect:
		trigger_trap()

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

func _on_auto_trigger_timeout() -> void:
	if do_detect and not is_flying_forward:
		trigger_trap()

# New function to handle trap triggering logic
func trigger_trap() -> void:
	do_detect = false
	is_alerted = true
	if invisible_before_launch:
		modulate.a = 1
	start_alert_shake()
