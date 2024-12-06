extends Area2D

@export var speed: float = Consts.FALLING_TRAP_SPEED  # 可配置的速度
@export var invisible_before_launch :bool = true  # 添加是否隐身的配置
@export var target: Area2D
@export var detection: Area2D

var is_flying_forward: bool = false
var fly_direction: Vector2 = Vector2.ZERO
var init_position: Vector2 = Vector2.ZERO
var final_position : Vector2 = Vector2.ZERO
var do_detect 

@onready var falling_trap: Area2D = $"."
@onready var timer: Timer = $Timer
@onready var animated_sprited_2d:  AnimatedSprite2D = $AnimatedSprite2D
@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var kill_zone_collision: CollisionShape2D = $kill_zone/CollisionShape2D

func _ready() -> void:
	do_detect = true 
	init_position = global_position
	final_position = target.global_position
	if invisible_before_launch:
		modulate.a = 0
	kill_zone_collision.disabled = true
	# 设置整个 Area2D 的旋转
	fly_direction = (final_position - global_position).normalized()
	var angle_to_target = fly_direction.angle()
	rotation = angle_to_target - PI/2  # 旋转整个节点
	
	detection.body_entered.connect(_on_detection_body_entered)
	animated_sprited_2d.play("default")

func _physics_process(delta):
	if is_flying_forward:
		global_position += fly_direction * speed * delta
		if global_position.distance_to(final_position) < 5:
			global_position = final_position
			kill_zone_collision.disabled = true
			modulate.a = 0
		
		

func _on_timer_timeout() -> void:
	is_flying_forward = true
	if invisible_before_launch:
		modulate.a = 1  # 发射时显示
	fly_direction = (final_position  - global_position).normalized()
	kill_zone_collision.disabled = false



# 添加新的检测函数
func _on_detection_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and do_detect:
		timer.start()
		do_detect=false
		if sfx_player:
			sfx_player.play()
