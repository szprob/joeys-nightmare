# @tool
extends Area2D

var debug_draw_enabled = true
# @export var gravity_space_override = SPACE_OVERRIDE_REPLACE

@export var tile_size := Vector2(32, 32) # 平铺大小
@export var snap_to_grid := true # 是否对齐网格

@export var one_time_use := false
@export var enabled_at_start := true
@export var arrow_length := 16.0
@export var arrow_color := Color.YELLOW
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_exited.connect(_on_body_exited)
	if not enabled_at_start:
		gravity_space_override = SPACE_OVERRIDE_DISABLED
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.pause() # 暂停动画

	update_sprite_rotation()

func update_sprite_rotation():
	if has_node("AnimatedSprite2D"):
		# 获取重力方向的角度（与 _draw 函数使用相同的逻辑）
		var gravity_dir = gravity_direction
		var angle = gravity_dir.normalized().angle()
		# 将精灵旋转到重力方向
		rotation = angle + PI / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	pass

func _draw():
	# 获取 Area2D 的重力方向
	var gravity_dir = gravity_direction
	var normalized_direction = gravity_dir.normalized()
	var end_point = normalized_direction * arrow_length
	
	# 只在重力覆盖启用时绘制
	if gravity_space_override != SPACE_OVERRIDE_DISABLED:
		# 绘制主线
		draw_line(Vector2.ZERO - end_point, end_point, arrow_color, 2.0)
		
		# 绘制箭头头部
		var arrow_head_length = arrow_length * 0.4
		var arrow_angle = normalized_direction.angle()
		var head_point1 = end_point + Vector2.from_angle(arrow_angle + PI * 0.8) * arrow_head_length
		var head_point2 = end_point + Vector2.from_angle(arrow_angle - PI * 0.8) * arrow_head_length
		
		draw_line(end_point, head_point1, arrow_color, 2.0)
		draw_line(end_point, head_point2, arrow_color, 2.0)

func open():
	"""如果和button连接，如果button被按下，调用这个函数的行为"""
	gravity_space_override = SPACE_OVERRIDE_REPLACE
	if has_node("AnimatedSprite2D"):
		# $AnimatedSprite2D.visible = true
		$AnimatedSprite2D.play()

func close():
	"""如果和button连接，如果button被松开，调用这个函数的行为"""
	
	gravity_space_override = SPACE_OVERRIDE_DISABLED
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.pause() # 暂停动画

# 添加编辑器中的位置吸附功能
func _notification(what: int) -> void:
	if Engine.is_editor_hint() and what == NOTIFICATION_TRANSFORM_CHANGED and snap_to_grid:
		# 将位置吸附到网格
		var snapped_pos = position.snapped(tile_size)
		if position != snapped_pos:
			position = snapped_pos

func _on_body_exited(body: Node2D) -> void:
	if one_time_use and body.is_in_group("player"):
		# 可以直接销毁，或添加一个短暂的视觉效果后再销毁
		# if has_node("AnimatedSprite2D"):
		# 	$AnimatedSprite2D.play("fade_out") # 如果有淡出动画的话
		# 	await $AnimatedSprite2D.animation_finished
		queue_free()
