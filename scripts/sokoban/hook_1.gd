extends Area2D
@export var radius: float = 10
var is_available: bool = false
@export var show_debug_draw: bool = false

@onready var sprite = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("hookable")
	update_appearance() # 初始化外观


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw() -> void:
	if not show_debug_draw:
		return
		
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

func set_available(value: bool) -> void:
	is_available = value
	update_appearance()


func update_appearance() -> void:
	if sprite: # 确保sprite存在
		sprite.frame = 1 if is_available else 0
