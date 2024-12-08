extends Area2D

var do_detect: bool = true
var timer: Timer
var timer2: Timer
var timer3: Timer
var timer4: Timer
var player: Node2D
var fade_overlay: ColorRect
var canvas_layer: CanvasLayer

@export var next_scene_file_path: String
@export var teleport_type: String = 'day2dream'
@export var time_scale: float = 5
@export var transition_scene: String = "res://scenes/modules/checkpoints/transition.tscn"  # 添加过渡场景路径

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	player = get_tree().get_first_node_in_group("player")
	GameManager.die_requested.connect(_on_die_requested)
	body_entered.connect(_on_body_entered)
	timer = Timer.new()
	timer.wait_time = time_scale
	timer.timeout.connect(_on_timeout)
	add_child(timer)
	timer2 = Timer.new()
	timer2.wait_time = time_scale
	timer2.timeout.connect(_on_timeout2)
	add_child(timer2)
	timer3 = Timer.new()
	timer3.wait_time = 1
	timer3.timeout.connect(_on_timeout3)
	add_child(timer3)
	timer4 = Timer.new()
	timer4.wait_time = 1
	timer4.timeout.connect(_on_timeout4)
	add_child(timer4)
	# 创建 CanvasLayer
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


func _on_timeout() -> void:
	player.set_can_move(false,'idle')
	timer2.start()

func _on_timeout2() -> void:
	finish()


func _on_die_requested() -> void:
	player.set_can_move(false,'death')
	finish()

func _on_timeout3() -> void:
	player.set_can_move(false,'death')
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(fade_overlay, "color:a", 1.0, 3)
	await tween.finished
	timer4.start()

func _on_timeout4() -> void:
	GameManager.game_state['target_scene'] = next_scene_file_path
	GameManager.game_state['teleport_type'] = teleport_type
	# GameManager.save_game_state()
	get_tree().change_scene_to_file(transition_scene)

func finish() -> void:
	timer3.start()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not do_detect:
		return
	do_detect = false
	GameManager.game_state_cache['should_die'] = false
	timer.start()
