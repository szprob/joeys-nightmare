# @tool
extends Area2D

var debug_draw_enabled = true
@export var arrow_length := 50.0
@export var arrow_color := Color.YELLOW
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
		draw_line(Vector2.ZERO, end_point, arrow_color, 2.0)
		
		# 绘制箭头头部
		var arrow_head_length = arrow_length * 0.2
		var arrow_angle = normalized_direction.angle()
		var head_point1 = end_point + Vector2.from_angle(arrow_angle + PI * 0.8) * arrow_head_length
		var head_point2 = end_point + Vector2.from_angle(arrow_angle - PI * 0.8) * arrow_head_length
		
		draw_line(end_point, head_point1, arrow_color, 2.0)
		draw_line(end_point, head_point2, arrow_color, 2.0)
