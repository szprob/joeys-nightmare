extends Area2D
@export var radius: float = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("hookable")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw() -> void:
	# Get collision shape size
	var shape_size = radius
	var color = Color.RED
	
	# Draw horizontal line
	draw_line(Vector2(-shape_size, 0), Vector2(shape_size, 0), color, 2.0)
	# Draw vertical line
	draw_line(Vector2(0, -shape_size), Vector2(0, shape_size), color, 2.0)

func get_hook_position() -> Vector2:
	# 返回钩爪目标位置（区域中心）
	return global_position
