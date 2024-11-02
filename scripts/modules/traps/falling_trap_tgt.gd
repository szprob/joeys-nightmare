extends Area2D

@export var speed: float = Consts.FALLING_TRAP_SPEED  # 可配置的速度
@export var invisible_before_launch :bool = true  # 添加是否隐身的配置
@export var target: Area2D
@export var detection: Area2D

var is_flying_forward: bool = false
var fly_direction: Vector2 = Vector2.ZERO
var init_position: Vector2 = Vector2.ZERO
var final_position : Vector2 = Vector2.ZERO
var do_detect = true 

@onready var falling_trap: Area2D = $"."
@onready var timer: Timer = $Timer
@onready var animated_sprited_2d:  AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	init_position = position
	final_position = target.global_position
	if invisible_before_launch:  # 根据配置设置初始可见性
		modulate.a = 0  # 完全透明
	# 添加 detection 区域的信号连接
	detection.body_entered.connect(_on_detection_body_entered)
	# 添加默认动画播放
	animated_sprited_2d.play("default")

func _physics_process(delta):
	if is_flying_forward:
		position += fly_direction * speed * delta
		if position.distance_to(final_position) < 5:
			position = final_position
			queue_free()
		
		

func _on_timer_timeout() -> void:
	is_flying_forward = true
	if invisible_before_launch:
		modulate.a = 1  # 发射时显示
	fly_direction = (final_position  - position).normalized()



# 添加新的检测函数
func _on_detection_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and do_detect:
		timer.start()
		do_detect=false
