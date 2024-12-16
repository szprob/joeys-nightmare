extends Node2D

@export var transition_scene: String = "res://scenes/modules/checkpoints/transition.tscn"  # 添加过渡场景路径
@export var target_scene: String = "res://scenes/dreams/bigworldv2/intro.tscn"

var buttons = []
var current_index = 0

@onready var new_button: Button = $new
@onready var load_button: Button = $load
@onready var ins_button: Button = $ins
@onready var staff_button: Button = $staff
@onready var quit_button: Button = $quit
@onready var logo: Sprite2D = $Sprite2D
@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var label: Label = $Label


func _ready():
	if not GameManager.game_state_cache['bmg_set']:
		GameManager.setup_bgm_player()
		GameManager.play_bgm('bgm')
	buttons = [new_button, load_button, ins_button, staff_button, quit_button]

	new_button.pressed.connect(_on_new_pressed)
	load_button.pressed.connect(_on_load_pressed)
	ins_button.pressed.connect(_on_ins_pressed)
	staff_button.pressed.connect(_on_staff_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# 为每个按钮添加焦点效果
	for button in buttons:
		button.focus_entered.connect(func(): _on_button_focus(button))
		button.focus_exited.connect(func(): _on_button_unfocus(button))
	buttons[current_index].grab_focus()

	if GameManager.game_state['finish']:
		if GameManager.game_state_cache['code'] != '':
			label.text = GameManager.game_state_cache['code']
		else:
			label.text = generate_string(10, 1028)
			GameManager.game_state_cache['code'] = label.text
		label.visible = true
	else:
		label.visible = false
	
func play_sfx():
	if sfx_player:
		sfx_player.play()

func _process(delta):
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

func _on_new_pressed() -> void:
	play_sfx()
	GameManager.init_default_state()
	GameManager.game_state['target_scene'] = target_scene
	GameManager.game_state['teleport_type'] = 'day2dream'
	GameManager.save_game_state()
	get_tree().change_scene_to_file(transition_scene)


func _on_load_pressed() -> void:
	play_sfx()
	GameManager.load_game_state()
	GameManager.apply_settings()
	# 创建过渡场景实例
	get_tree().change_scene_to_file(transition_scene)

func _on_quit_pressed() -> void:
	play_sfx()
	get_tree().quit()


func _on_ins_pressed() -> void:
	play_sfx()
	get_tree().change_scene_to_file("res://scenes/main/ins.tscn")

func _on_staff_pressed() -> void:
	play_sfx()
	get_tree().change_scene_to_file("res://scenes/main/staff.tscn")

# 添加这些新函数
func _on_button_focus(button: Button) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 放大效果
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)
	# 高亮效果
	tween.tween_property(button, "modulate", Color(1.2, 1.2, 1.2), 0.1)
	
	# 添加粗边框
	var stylebox = StyleBoxFlat.new()
	stylebox.set_border_width_all(4)  # 设置边框宽度
	stylebox.border_color = Color(1, 1, 1)  # 设置边框颜色为白色
	stylebox.bg_color = Color(0, 0, 0, 0)  # 背景透明
	button.add_theme_stylebox_override("focus", stylebox)

func _on_button_unfocus(button: Button) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(button, "modulate", Color(1, 1, 1), 0.1)
	
	# 移除边框
	button.remove_theme_stylebox_override("focus")


func sum(arr: Array) -> int:
	var total = 0
	for num in arr:
		total += num
	return total

func generate_string(length: int, target_sum: int) -> String:
	var characters = "abcdefghijklmnopqrstuvwxyz"
	var result = []
	var remaining_sum = target_sum
	
	# 为前n-1个位置生成随机字符
	for i in range(length - 1):
		# 计算剩余位置所需的最小和最大可能值
		var positions_left = length - i
		var min_possible = positions_left * "a".to_ascii_buffer()[0]  # 所有剩余位置都是'a'
		var max_possible = positions_left * "z".to_ascii_buffer()[0]  # 所有剩余位置都是'z'
		
		# 计算当前位置可以使用的字符范围
		var min_current = max(("a".to_ascii_buffer()[0]), remaining_sum - max_possible + "z".to_ascii_buffer()[0])
		var max_current = min(("z".to_ascii_buffer()[0]), remaining_sum - min_possible + "a".to_ascii_buffer()[0])
		
		# 在可用范围内随机选择一个ASCII值
		var target_ascii = randi() % (max_current - min_current + 1) + min_current
		
		# 找到最接近这个ASCII值的可用字符
		var chosen_char = "a"
		var min_diff = 999
		for c in characters:
			var diff = abs(c.to_ascii_buffer()[0] - target_ascii)
			if diff < min_diff:
				min_diff = diff
				chosen_char = c
		
		result.append(chosen_char)
		remaining_sum -= chosen_char.to_ascii_buffer()[0]
	
	# 最后一个位置用于平衡总和
	var last_ascii = remaining_sum
	var last_char = "a"
	var min_diff = 999
	for c in characters:
		var diff = abs(c.to_ascii_buffer()[0] - last_ascii)
		if diff < min_diff:
			min_diff = diff
			last_char = c
	
	result.append(last_char)
	
	# 随机打乱结果
	result.shuffle()
	
	return "".join(PackedStringArray(result))
