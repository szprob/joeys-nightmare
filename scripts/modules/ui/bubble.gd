extends Node2D

@onready var bubble_panel: Panel = $Panel
@onready var label: Label = $Panel/Label


@export var t: float = 1
@export var text: String = "hello world"
@export var text_speed: float = 0.04  # 每个字符显示的间隔时间

func _ready() -> void:
	# 初始化时显示气泡
	await show_bubble()  # 等待文字显示完成
	
	# 文字显示完成后等待t秒再销毁
	var timer = get_tree().create_timer(t)
	timer.timeout.connect(func():
		queue_free()
	)

func show_bubble() -> void:
	# 设置文本内容和字体大小
	var full_text = text
	label.text = ""  # 初始化为空文本
	label.add_theme_font_size_override("font_size", 10)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 等待一帧让 Label 更新尺寸
	await get_tree().process_frame
	
	# # 设置更舒适的内边距和最小尺寸
	# var text_size: Vector2 = label.get_minimum_size()
	# var min_width: float = max(text_size.x, 100.0)
	
	# # 设置面板尺寸和样式，使用固定的三行高度
	# bubble_panel.custom_minimum_size = Vector2(min_width, 40)
	bubble_panel.visible = true
	
	# 逐字显示文本
	for i in range(full_text.length()):
		label.text += full_text[i]
		await get_tree().create_timer(text_speed).timeout  # 每个字符之间等待0.05秒

	