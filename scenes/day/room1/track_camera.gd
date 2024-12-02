extends Camera2D
const grid_size = 0

@onready var camera_h: int = limit_right - limit_left - grid_size
@onready var camera_v: int = limit_bottom - limit_top - grid_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	limit_left = floor($"..".position.x / camera_h) * camera_h
	limit_right = limit_left + camera_h + grid_size
	
	limit_top = floor($"..".position.y / camera_v) * camera_v
	limit_bottom = limit_top + camera_v + grid_size
	# print("camera: ", limit_left, ", ", limit_right, ", ", limit_top, ", ", limit_bottom)
