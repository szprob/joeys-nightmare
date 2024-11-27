extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialogue_area: Area2D = $DialogueArea

enum NPCState {
	IDLE,
	WALKING,
}

var current_state: NPCState = NPCState.IDLE
var movement_speed: float = 100.0
var dialogue_data: Dictionary = {}
var can_interact: bool = true
var player_in_range: bool = false
var is_dialogue_active: bool = false

# 添加新的导入
const DialogueResourceFile = preload("res://addons/dialogue_manager/dialogue_resource.gd")
const DialogueManagerFile = preload("res://addons/dialogue_manager/dialogue_manager.gd")
const PortalScene = preload("res://scenes/modules/checkpoints/empty-teleport.tscn")
const BubbleScene = preload("res://scenes/modules/ui/bubble.tscn")

# 添加新的变量
@export var target_position: Vector2 = Vector2(0, 0)
@export var texts: Vector2 = Vector2(0, 0)
@export var bubble_delay: float = 1.0
@export var bubble_texts: Array[String] = ['player:你好你好你好你好你好你好你好你好你好你好你好你好你好你好','npc:你好你好你好你好你好你好你好你好你好你好你好你好你好你好']
var timer: Timer
@export var bubble_index: int = 0

func _ready() -> void:
	# 初始化对话区域信号
	dialogue_area.body_entered.connect(_on_dialogue_area_body_entered)
	dialogue_area.body_exited.connect(_on_dialogue_area_body_exited)
	_update_animation()

	# 创建并初始化计时器
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	timer.wait_time = bubble_delay
	timer.start()



# 	var player = get_tree().get_first_node_in_group("player")
# 	if player and player.has_method("set_can_move"):
# 		player.set_can_move(false)
# 	# 添加: 延迟一帧后自动开始对话
# 	await get_tree().create_timer(0.1).timeout
# 	GameManager.start_dialogue()
# 	GameManager.show_dialogue(dialogue_resource, dialogue_start).tree_exited.connect(_on_dialog_finished)

# func _on_dialog_finished() -> void:
# 	var player = get_tree().get_first_node_in_group("player")
# 	if player and player.has_method("set_can_move"):
# 		player.set_can_move(true)

# 添加新的函数


func _on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(false)
	create_bubble()


func _physics_process(delta: float) -> void:
	if not visible:
		queue_free()

	if velocity.x < 0.01 and velocity.y < 0.01 and velocity.x > -0.01 and velocity.y > -0.01:
		current_state = NPCState.IDLE
	else:
		current_state = NPCState.WALKING

	_update_animation()
	match current_state:
		NPCState.IDLE:
			_process_idle_state()
		NPCState.WALKING:
			_process_walking_state(delta)

func _process_idle_state() -> void:
	pass

func _process_walking_state(delta: float):

    
	# 计算到目标的距离
	var distance = global_position.distance_to(target_position)
	if distance < 5.0:  # 到达目标的阈值
		current_state = NPCState.IDLE
		position = target_position
	else:
		var direction = global_position.direction_to(target_position)
		velocity = direction * movement_speed
		position += velocity * delta
		

func _update_animation() -> void:
	match current_state:
		NPCState.IDLE:
			animated_sprite.play("idle")
		NPCState.WALKING:
			animated_sprite.play("move")
			# 根据移动方向翻转精灵
			animated_sprite.flip_h = velocity.x < 0

func set_movement_target(target_pos: Vector2) -> void:
	target_position = target_pos
	current_state = NPCState.WALKING


func _on_dialogue_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_dialogue_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func set_dialogue_data(data: Dictionary) -> void:
	dialogue_data = data

func set_interactable(value: bool) -> void:
	can_interact = value

# 添加新的函数
func create_portal_and_disappear(portal_position: Vector2) -> void:
	# 创建传送门实例
	var portal = PortalScene.instantiate()
	get_parent().add_child(portal)
	portal.global_position = portal_position
	
	# NPC走向传送门
	set_movement_target(portal_position)
	
	# 添加信号监听以检测NPC是否到达传送门位置
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func():
		if position.distance_to(portal_position) < 5.0:
			visible = false  # 使NPC消失
			portal.queue_free()  # 删除传送门
	)



func create_bubble() -> void:
	var bubble_instance = BubbleScene.instantiate()
	get_parent().add_child(bubble_instance)
	
	# 获取当前文本并处理前缀
	var current_text = bubble_texts[bubble_index]
	var bubble_position = global_position + Vector2(-48, -53)  # 默认NPC位置
	
	if current_text.begins_with("player:"):
		# 如果是玩家对话，找到玩家并设置位置
		var player = get_tree().get_first_node_in_group("player")
		if player:
			bubble_position = player.global_position + Vector2(-48, -53)
		current_text = current_text.substr(7)  # 删除"player:"前缀
	elif current_text.begins_with("npc:"):
		current_text = current_text.substr(4)  # 删除"npc:"前缀
	
	bubble_instance.text = current_text
	bubble_instance.global_position = bubble_position
	bubble_instance.tree_exited.connect(_on_bubble_destroyed)

func _on_bubble_destroyed() -> void:
	bubble_index += 1
	if bubble_index < bubble_texts.size():
		create_bubble()
	else:
		create_portal_and_disappear(target_position)
