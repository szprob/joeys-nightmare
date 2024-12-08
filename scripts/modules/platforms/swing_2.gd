extends CharacterBody2D


const SPEED = 150.0

var start_play: bool = false
var do_detect: bool = true
var player: Node2D
var timer: Timer
var fade_overlay
var canvas_layer
var do_draw: bool = true
@export var pivot_target: Area2D  # 枢轴点位置
@export var rope_color: Color = Color.WHEAT  # 绳子颜色
@export var rope_width: float = 2.0  # 绳子宽度
@export var next_scene_file_path: String = ""
@export var transition_scene: String = "res://scenes/modules/checkpoints/transition.tscn"  # 添加过渡场景路径
@export var teleport_type: String = "dream2day"

@onready var animated_sprite: AnimatedSprite2D = $boss
@onready var detection: Area2D = $detection
@onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D
func _ready():
	await get_tree().create_timer(0.1).timeout
	animated_sprite.visible = false
	# 获取检测区域节点
	detection.body_entered.connect(_on_detection_body_entered)
	
	timer = Timer.new()
	timer.wait_time = 1
	timer.timeout.connect(_on_timeout)
	add_child(timer)


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
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if start_play:
		velocity += get_gravity() * delta
		if velocity.y > SPEED:
			velocity.y = SPEED
		move_and_slide()

func _draw():
	if not do_draw:
		return

	if start_play:
		return
	
	# 画出从枢轴点到座位的绳子
	var local_pivot = to_local(pivot_target.global_position)
	# 根据当前角度旋转绳子的绘制,而不是整个节点
	draw_line(
		local_pivot,
		Vector2.ZERO,
		rope_color,
		rope_width
	)


func _on_detection_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and do_detect:
		do_detect=false
		animated_sprite.visible = true
		animated_sprite.play()
		player.set_can_move(false,'idle')
		await get_tree().create_timer(0.8).timeout
		start_play = true
		audio_stream.play()
		queue_redraw()
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(fade_overlay, "color:a", 1.0, 3)
		await tween.finished
		timer.start()


func _on_timeout() -> void:
	GameManager.game_state['target_scene'] = next_scene_file_path
	GameManager.game_state['teleport_type'] = teleport_type
	# GameManager.save_game_state()
	get_tree().change_scene_to_file(transition_scene)
