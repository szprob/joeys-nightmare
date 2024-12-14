extends Area2D

enum TeleportType { ONE_WAY, BI_WAY } 
enum Way { IN, OUT }

@export var teleport_type: TeleportType = TeleportType.ONE_WAY
@export var teleport_cooldown_time: float = 0.8
@export var teleport_time: float = 0.1
@export var way: Way = Way.IN
@export var keep_end_vec: bool = true
# 添加配对传送门的引用
@export var paired_portal: Area2D
@export var target: Area2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = Timer.new() #teleport_cooldown_time
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var timer2 : Timer = Timer.new() #teleport_time


# 添加一个变量来存储当前传送的物体
var current_body: Node2D = null

# 添加字典来跟踪不同物体的冷却状态
var cooldown_states: Dictionary = {}

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
		
	# 保存当前传送的物体引用
	current_body = body
	
	if timer2.is_stopped():
		timer2.start()

func _can_teleport(body: Node2D) -> bool:
	# 基础检查
	if not body.is_in_group("teleport_enable"):
		return false
		
	if way == Way.OUT:
		return false

	# 如果物体不在冷却字典中，初始化为true（可以传送）
	if not cooldown_states.has(body):
		cooldown_states[body] = true
		
	# 检查冷却状态
	if not cooldown_states[body]:
		return false
	
	if paired_portal != null or target != null:
		return true
	
	return false

func _on_timer_timeout() -> void:
	# 将当前传送物体的冷却状态设置为true（可以传送）
	for b in cooldown_states:
		cooldown_states[b] = true
	

func _on_timer2_timeout() -> void:
	var destination: Node2D = null
	
	if teleport_type == TeleportType.ONE_WAY:
		destination = paired_portal if paired_portal else target
	else:
		destination = paired_portal
		
	if destination and current_body:
		if audio_player and audio_player.stream:
			audio_player.play()
			
		var target_pos = destination.global_position
		var offset = Vector2.ZERO
		
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(target_pos, target_pos)
		var result = space_state.intersect_ray(query)
		
		if result:
			offset = Vector2(32, 0)
			
		current_body.global_position = target_pos + offset
		if not keep_end_vec:
			current_body.velocity = Vector2.ZERO
		
		# 设置冷却状态为false（不能传送）
		cooldown_states[current_body] = false
		timer.start()
		
		current_body = null
