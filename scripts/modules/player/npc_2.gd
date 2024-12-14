extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_2: AnimatedSprite2D = $boss
@onready var teleport_audio: AudioStreamPlayer2D = $teleport_audio
@onready var shoot_audio: AudioStreamPlayer2D = $shoot_audio
@onready var detection_area: Area2D = $detection
@onready var teleport: Node2D = $teleport
@onready var teleport2: Node2D = $teleport2
@onready var label: Label = $Label

enum NPCState {
	IDLE,
	DEAD,
}

var current_state: NPCState = NPCState.IDLE
var movement_speed: float = 100.0
var dialogue_file
var target_position: Vector2 = Vector2(0,0)
var timer: Timer
var timer2: Timer
var timer3: Timer
var timer4: Timer
var timer5: Timer
var timer6: Timer
var timer7: Timer

var fade_overlay
var canvas_layer
var bubble_texts: Array = []
var player : CharacterBody2D

var ball_instance 

# 添加新的导入
const PortalScene = preload("res://scenes/modules/checkpoints/empty-teleport.tscn")
const BubbleScene = preload("res://scenes/modules/ui/bubble.tscn")
const DialogueFile = preload("res://scenes/dreams/dialogue/dialogue.gd")
const BallScene = preload("res://scenes/enemy/ball.tscn")

# 添加新的变量
@export var shoot_delay: float = 0.1
@export var bubble_index: int = 0
@export var disappear_delay: float = 1.5
@export var next_scene_file_path: String = ""
@export var transition_scene: String = "res://scenes/modules/checkpoints/transition.tscn"  # 添加过渡场景路径
@export var teleport_type: String = "dream2day"



func _ready() -> void:
	await get_tree().create_timer(0.1).timeout 
	dialogue_file = DialogueFile.new()
	# 检查对话文件是否在已完成列表中
	# if GameManager.game_state.has('npc_dialogue_list') and bubble_title in GameManager.game_state['npc_dialogue_list']:
	# 	print('该NPC对话已完成，将被移除: ', bubble_title)
	# 	if teleport:
	# 		teleport.queue_free()
	# 	queue_free()
	# 	return
	label.visible = false
	animated_sprite.visible = false
	animated_sprite_2.visible = true

	detection_area.body_entered.connect(_on_body_entered)
	player = get_tree().get_first_node_in_group("player")

	# teleport = PortalScene.instantiate()
	teleport.global_position = global_position
	teleport.visible = false
	# add_child(teleport)
	# teleport2 = PortalScene.instantiate()
	teleport2.global_position = player.global_position
	teleport2.visible = false
	# add_child(teleport2)

	# disable player move
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	timer.wait_time = 0.1
	
	# # ball 
	# timer2 = Timer.new()
	# add_child(timer2)
	# timer2.timeout.connect(_on_timer2_timeout)
	# timer2.one_shot = true
	# timer2.wait_time = 1.5

	# # teleport npc 
	# timer3 = Timer.new()
	# add_child(timer3)
	# timer3.timeout.connect(_on_timer3_timeout)
	# timer3.one_shot = true
	# timer3.wait_time = 0.3

	# # npc死 
	# timer4 = Timer.new()
	# add_child(timer4)
	# timer4.timeout.connect(_on_timer4_timeout)
	# timer4.one_shot = true
	# timer4.wait_time = 3

	# # 玩家传送 
	# timer5 = Timer.new()
	# add_child(timer5)
	# timer5.timeout.connect(_on_timer5_timeout)
	# timer5.one_shot = true
	# timer5.wait_time = 1

	# # 说话
	# timer6 = Timer.new()
	# add_child(timer6)
	# timer6.timeout.connect(_on_timer6_timeout)
	# timer6.one_shot = true
	# timer6.wait_time = 1.5

	timer7 = Timer.new()
	add_child(timer7)
	timer7.timeout.connect(_on_timer7_timeout)
	timer7.one_shot = true
	timer7.wait_time = 1

	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # 确保在最上层
	add_child(canvas_layer)

	# 创建 ColorRect 并添加到 CanvasLayer
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color(1, 0.98, 0.94, 0)  # 略微偏米色的白色
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)  # 铺满整个屏幕
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var viewport_size = get_viewport_rect().size
	fade_overlay.custom_minimum_size = viewport_size
	fade_overlay.size = viewport_size
	canvas_layer.add_child(fade_overlay)




func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		timer.start()

#玩家不能动
func _on_timer_timeout():
	if player and player.has_method("set_can_move"):
		player.set_can_move(false,'idle')
	create_bubble("befor_die",0.1)
	# label.visible = true
	await get_tree().create_timer(1).timeout
	# label.visible = false
	animated_sprite_2.play("shoot")
	shoot_audio.play()
	await get_tree().create_timer(0.5).timeout
	ball_instance = BallScene.instantiate()
	var offset = animated_sprite_2.global_position + Vector2(70, 0)
	ball_instance.global_position = offset
	ball_instance.set_target(self)
	get_tree().current_scene.add_child(ball_instance)
	await get_tree().create_timer(0.5).timeout
	teleport.visible = true
	teleport_audio.play()
	await get_tree().create_timer(0.3).timeout
	teleport.visible = false
	animated_sprite.visible = true
	await get_tree().create_timer(0.9).timeout
	animated_sprite.play("death")
	await get_tree().create_timer(3).timeout
	teleport2.global_position = player.global_position
	teleport2.visible = true
	teleport_audio.play()
	await get_tree().create_timer(0.5).timeout
	player.visible = false
	await get_tree().create_timer(0.5).timeout
	teleport2.visible = false
	await get_tree().create_timer(1).timeout
	create_bubble("die",0.5)
	await get_tree().create_timer(3).timeout
	change_scene()
# 说话结束
func _on_timer7_timeout() -> void:
	GameManager.game_state['target_scene'] = next_scene_file_path
	GameManager.game_state['teleport_type'] = teleport_type
	# GameManager.save_game_state()
	get_tree().change_scene_to_file(transition_scene)


func create_bubble(bubble_title,bubble_speed) -> void:
	# 首先获取当前文本并处理前缀
	bubble_texts = dialogue_file.dialogue_data[bubble_title]
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
	bubble_instance.z_index = 101
	bubble_instance.visible = true
	# bubble_instance.text_speed = 0.5
	bubble_instance.text_speed = bubble_speed
	bubble_instance.global_position = bubble_position
	bubble_instance.tree_exited.connect(_on_bubble_destroyed)

	get_parent().add_child(bubble_instance)

func _on_bubble_destroyed() -> void:
	await get_tree().create_timer(0.1).timeout
# 	bubble_index += 1
# 	if bubble_index < bubble_texts.size():
# 		create_bubble()
# 	else:
# 		return 

func change_scene() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(fade_overlay, "color:a", 1.0, 3)
	await tween.finished
	timer7.start()
