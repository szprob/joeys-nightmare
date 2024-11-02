extends Area2D

enum TeleportType {DAY2DREAM,DREAM2DAY} 

@export var teleport_time: float = 0.1
@export var target_scene: String = "res://scenes/day/game/game.tscn"
@export var teleport_type: TeleportType = TeleportType.DREAM2DAY
@export var transition_scene: String = "res://scenes/modules/checkpoints/transition.tscn"  # 添加过渡场景路径

var player_inside = false  # 用于跟踪玩家是否在存档点内
var next_scene_resource: Resource  # 用于存储预加载的场景

@onready var timer: Timer = Timer.new() #teleport_time
@onready var label: Label = $Label # 按键提醒
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# 添加计时器
	add_child(timer)
	timer.wait_time = teleport_time
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	label.visible = false

	var original_color = animated_sprite_2d.modulate
	# 调整为偏红色
	var red_tint = Color(1.0, 0.4, 0.4, 1.0)  # 使用较高的红色值，较低的绿色和蓝色值
	var inverted_color = Color(1, 1, 1, 1) - original_color + Color(0, 0, 0, 1)
	animated_sprite_2d.modulate = inverted_color.blend(red_tint)


func _process(_delta):
	if Input.is_action_just_pressed("select") and player_inside:
		timer.start()

func _on_body_entered(body: CharacterBody2D) -> void:
	if body is CharacterBody2D:
		player_inside = true
		label.visible = true
	
func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		player_inside = false
		label.visible = false



func _on_timer_timeout():
	# 创建过渡场景实例
	var transition_instance = load(transition_scene).instantiate()
	# 将目标场景路径传递给过渡场景
	transition_instance.next_scene_path = target_scene
	# 将过渡类型传递给过渡场景
	transition_instance.teleport_type = teleport_type
	# 添加过渡场景到根节点
	get_tree().root.add_child(transition_instance)
	# 移除当前场景
	get_tree().current_scene.queue_free()
