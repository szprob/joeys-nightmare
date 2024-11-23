extends Node2D

var current_index = 0
var buttons = []
@onready var continue_button: Button = $VBoxContainer/continue
@onready var main_menu_button: Button = $VBoxContainer/main_menu
@onready var quit_button: Button = $VBoxContainer/quit
@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var buttons_container: VBoxContainer = $VBoxContainer

# 添加背景矩形的引用
var background_rect: ColorRect

var can_process_input = false  # 新增：控制是否处理输入的标志
@onready var input_timer: Timer = Timer.new()  # 新增：计时器

func _ready() -> void:
	# 修改这些初始设置
	process_mode = Node.PROCESS_MODE_ALWAYS
	# z_index = 100  # 确保在最上层
	
	# 创建半透明背景
	background_rect = ColorRect.new()
	# 设置为全屏
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	# 设置黑色半透明背景
	background_rect.color = Color(0, 0, 0, 0.5)  # 最后的 0.5 是透明度（0-1）
	# 确保背景在按钮下面
	background_rect.z_index = -1
	
	# 将背景添加到场景中
	add_child(background_rect)
	# 将背景移动到所有其他元素的后面
	move_child(background_rect, 0)
	
	# 设置按钮
	buttons = [continue_button, main_menu_button, quit_button]
	buttons[current_index].grab_focus()
	# 连接信号
	continue_button.pressed.connect(_on_continue_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	# 确保所有子节点都不受暂停影响
	set_process_mode_recursive(self)
	
	# 设置按钮容器的宽度
	buttons_container.custom_minimum_size.x = 180  # 设置宽度为200像素
	
	# 如果想让所有按钮都使用相同的宽度
	for button in buttons:
		button.custom_minimum_size.x = 150  # 按钮宽度稍小于容器
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER  # 居中对齐
	
	# 设置并启动计时器
	input_timer.one_shot = true  # 设置为一次性计时器
	input_timer.wait_time = 0.7  # 设置等待时间为0.5秒
	input_timer.timeout.connect(_on_input_timer_timeout)
	add_child(input_timer)
	input_timer.start()

# 添加这个新函数
func set_process_mode_recursive(node: Node) -> void:
	node.process_mode = Node.PROCESS_MODE_ALWAYS
	for child in node.get_children():
		set_process_mode_recursive(child)

func play_sfx():
	if sfx_player:
		sfx_player.play()

func _process(_delta):
	if !can_process_input:  # 如果还不能处理输入，直接返回
		return
		
	if Input.is_action_just_pressed("down"):
		current_index = (current_index + 1) % buttons.size()
		buttons[current_index].grab_focus()
		play_sfx()
	elif Input.is_action_just_pressed("up"):
		current_index = (current_index - 1 + buttons.size()) % buttons.size()
		buttons[current_index].grab_focus()
		play_sfx()
	elif Input.is_action_just_pressed("main_scene_select"):
		buttons[current_index].emit_signal("pressed")
		play_sfx()
	elif Input.is_action_just_pressed("esc"):
		play_sfx()
		GameManager.resume_game()

# 新增：计时器超时回调函数
func _on_input_timer_timeout() -> void:
	can_process_input = true

func _on_continue_button_pressed() -> void:
	play_sfx()
	GameManager.resume_game()

func _on_main_menu_button_pressed() -> void:
	play_sfx()
	GameManager.resume_game()  # 确保取消暂停状态
	queue_free()  # 确保暂停菜单被移除
	get_tree().change_scene_to_file("res://scenes/main/start.tscn")

func _on_quit_button_pressed() -> void:
	play_sfx()
	get_tree().quit()
