extends Area2D

@export var disapper_time: float = 0.8
@export var teleport_time: float = 0.1
# 添加配对传送门的引用
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var timer : Timer = Timer.new() #teleport_time
@onready var timer2 : Timer = Timer.new() #teleport_time
@onready var tween: Tween

var have_start: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 添加计时器
	add_child(timer)
	timer.wait_time = teleport_time
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer2)
	timer2.wait_time = disapper_time
	timer2.one_shot = true
	timer2.timeout.connect(_on_timer2_timeout)

	# 建立信号连接
	body_entered.connect(_on_body_entered)
	# 根据传送方向设置动画
	animated_sprite_2d.play("portal_in")
	
func _on_body_entered(body: Node2D) -> void:

	if not _can_teleport(body):
		return
	if not have_start:
		timer.start()
		have_start = true

func _can_teleport(body: Node2D) -> bool:
	# 基础检查
	if not body.is_in_group("teleport_enable"):
		return false
		
	return true

func _on_timer_timeout(body: Node2D) -> void:
	# 将当前传送物体的冷却状态设置为true（可以传送）
	body.visible = false
	timer2.start()

func _on_timer2_timeout() -> void:
	tween = create_tween()
	
	# 设置渐变效果
	tween.tween_property(animated_sprite_2d, "modulate:a", 0, 1.0)
	tween.tween_property(collision_shape_2d, "disabled", true, 1.0)
	
	tween.tween_all_completed.connect(_on_tween_all_completed)

func _on_tween_all_completed() -> void:
	queue_free()
