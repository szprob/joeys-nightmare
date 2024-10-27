extends Camera2D
@onready var camera_h: int = limit_right - limit_left
@onready var camera_v: int = limit_bottom - limit_top

func fix_border(limit:int):
	if limit > 0 :
		limit -= 16
	if limit < 0 :
		limit += 16
	return limit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	limit_left = fix_border(floor($"..".position.x / camera_h) * camera_h) 
	limit_right = limit_left + camera_h
	
	limit_top = fix_border(floor($"..".position.y / camera_v) * camera_v)
	limit_bottom = limit_top + camera_v
