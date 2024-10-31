extends Area2D

enum TeleportType { ONE_WAY, BI_WAY } 
enum Way { IN, OUT }

@export var teleport_type: TeleportType = TeleportType.ONE_WAY
@export var teleport_cooldown_time: float = 1.0
@export var teleport_time: float = 0.5
@export var way: Way = Way.IN
# 添加配对传送门的引用
@export var paired_portal: Area2D
@export var target: Area2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = Timer.new()
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var timer2 : Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 添加计时器
	add_child(timer)
	timer.wait_time = teleport_cooldown_time
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
	# 添加第二个计时器
	add_child(timer2)
	timer2.wait_time = teleport_time
	timer2.one_shot = true
	timer2.timeout.connect(_on_timer2_timeout)

	# 建立信号连接
	body_entered.connect(_on_body_entered)
	
	# 根据传送方向设置动画
	if way == Way.IN:
		animated_sprite_2d.play("portal_in")
	else:
		animated_sprite_2d.play("portal_out")
	
	# 设置传送门颜色
	if teleport_type == TeleportType.BI_WAY:
		if way == Way.OUT:
			var original_color = animated_sprite_2d.modulate
			# 调整为更浅的蓝色
			var blue_tint = Color(0.4, 0.6, 1.0, 1.0)  # 增加红色和绿色的值，使蓝色更浅
			var inverted_color = Color(1, 1, 1, 1) - original_color + Color(0, 0, 0, 1)
			animated_sprite_2d.modulate = inverted_color.blend(blue_tint)

func _on_body_entered(body: Node2D) -> void:
	# 检查是否可以传送
	if not _can_teleport(body):
		return

	if timer2.is_stopped():
		timer2.start()


func _can_teleport(body: Node2D) -> bool:
	# 基础检查
	if not body.is_in_group("teleport_enable") or not GameManager.game_state['teleport_enable']:
		return false
	
	# 检查传送类型和方向
	if way == Way.OUT:
		return false


	if paired_portal != null or target != null:
		return true
	
	return false



func _on_timer_timeout() -> void:
	GameManager.game_state['teleport_enable'] = true
	# 重置动画
	if way == Way.IN:
		animated_sprite_2d.play("portal_in")
	else:
		animated_sprite_2d.play("portal_out")


func _on_timer2_timeout() -> void:
	# 执行传送
	var destination: Node2D = null
	
	if teleport_type == TeleportType.ONE_WAY:
		destination = paired_portal if paired_portal else target
	else:
		destination = paired_portal
		
	if destination:
		# # 播放传送动画
		# animated_sprite_2d.play("teleport")
		# if paired_portal:
		# 	paired_portal.animated_sprite_2d.play("receive")
		
		# 传送物体
		body.global_position = destination.global_position
		
		# 禁用传送功能直到计时器超时
		GameManager.game_state['teleport_enable'] = false
		timer.start()