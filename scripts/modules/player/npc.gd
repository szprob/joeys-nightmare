extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialogue_area: Area2D = $DialogueArea
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D



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
var target_position: Vector2 = Vector2(0,0)
var timer: Timer
var disappear_timer: Timer
var bubble_texts: Array = []

# 添加新的导入
const DialogueResourceFile = preload("res://addons/dialogue_manager/dialogue_resource.gd")
const DialogueManagerFile = preload("res://addons/dialogue_manager/dialogue_manager.gd")
const PortalScene = preload("res://scenes/modules/checkpoints/empty-teleport.tscn")
const BubbleScene = preload("res://scenes/modules/ui/bubble.tscn")

# 添加新的变量
@export var bubble_delay: float = 1.2
@export var bubble_speed: float = 0.06
@export var bubble_file: String = "res://assets/dialogue/start.txt"
@export var bubble_index: int = 0
@export var teleport: Node2D
@export var disappear_delay: float = 1.5
@export var player : CharacterBody2D

func _ready() -> void:
	if bubble_file in GameManager.game_state['npc_dialogue_list']:
		teleport.queue_free()
		queue_free()
		return
	teleport.visible = false
	# 初始化对话区域信号
	# dialogue_area.body_entered.connect(_on_dialogue_area_body_entered)
	# dialogue_area.body_exited.connect(_on_dialogue_area_body_exited)
	_update_animation()

	# 创建并初始化计时器
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	timer.wait_time = bubble_delay
	timer.start()

	disappear_timer = Timer.new()
	add_child(disappear_timer)
	disappear_timer.timeout.connect(_on_disappear_timer_timeout)
	disappear_timer.one_shot = true
	disappear_timer.wait_time = disappear_delay


	bubble_texts = GameManager.read_txt_to_list(bubble_file)


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
	if player and player.has_method("set_can_move"):
		player.set_can_move(false)
	create_bubble()


func _physics_process(delta: float) -> void:

	# if velocity.x < 0.01 and velocity.y < 0.01 and velocity.x > -0.01 and velocity.y > -0.01:
	# 	current_state = NPCState.IDLE
	# else:
	# 	current_state = NPCState.WALKING

	_update_animation()
	match current_state:
		NPCState.IDLE:
			_process_idle_state()
		NPCState.WALKING:
			_process_walking_state(delta)

func _process_idle_state() -> void:
	pass

func _process_walking_state(_delta: float):
	# 添加调试信息
	var distance = position.distance_to(target_position)
	if distance < 5.0:
		current_state = NPCState.IDLE
		position = target_position
		disappear()
	else:
		var direction = position.direction_to(target_position)
		velocity = direction * movement_speed
		
		if velocity.length() > 0:
			move_and_slide()

func _update_animation() -> void:
	match current_state:
		NPCState.IDLE:
			animated_sprite.play("idle")
		NPCState.WALKING:
			animated_sprite.play("move")
			# 根据移动方向翻转精灵
			animated_sprite.flip_h = velocity.x < 0

# func _on_dialogue_area_body_entered(body: Node2D) -> void:
# 	if body.is_in_group("player"):
# 		player_in_range = true

# func _on_dialogue_area_body_exited(body: Node2D) -> void:
# 	if body.is_in_group("player"):
# 		player_in_range = false

# func set_dialogue_data(data: Dictionary) -> void:
# 	dialogue_data = data

# func set_interactable(value: bool) -> void:
# 	can_interact = value

# 添加新的函数
func create_portal() -> void:
	teleport.visible = true
	# 添加调试信息
	print("Teleport global position:", teleport.global_position)
	target_position = teleport.global_position
	print("Target position (local):", target_position)
	print("Current position:", position)
	current_state = NPCState.WALKING

func disappear() -> void:
	visible = false
	if audio_player and audio_player.stream:
		audio_player.play()
	if player and player.has_method("set_can_move"):
		player.set_can_move(true)
	disappear_timer.start()

func _on_disappear_timer_timeout() -> void:
	teleport.queue_free()
	queue_free()


func create_bubble() -> void:
	# 首先获取当前文本并处理前缀
	var current_text = bubble_texts[bubble_index]
	var bubble_position = global_position + Vector2(-48, -53)  # 默认NPC位置
	
	if current_text.begins_with("player:"):
		if player:
			bubble_position = player.global_position + Vector2(-48, -53)
		current_text = current_text.substr(7)
	elif current_text.begins_with("npc:"):
		current_text = current_text.substr(4)
	
	# 然后创建气泡实例并使用处理后的文本
	var bubble_instance = BubbleScene.instantiate()
	bubble_instance.text = current_text
	bubble_instance.t = bubble_delay
	bubble_instance.text_speed = bubble_speed
	bubble_instance.global_position = bubble_position
	bubble_instance.tree_exited.connect(_on_bubble_destroyed)
	get_parent().add_child(bubble_instance)

func _on_bubble_destroyed() -> void:
	bubble_index += 1
	if bubble_index < bubble_texts.size():
		create_bubble()
	else:
		GameManager.game_state['npc_dialogue_list'].append(bubble_file)
		GameManager.save_game_state()
		create_portal()
