extends Camera2D
const grid_size = 16

@onready var camera_h: int = limit_right - limit_left - grid_size
@onready var camera_v: int = limit_bottom - limit_top - grid_size

func _ready() -> void:
	GameManager.camera_shake_requested.connect(_on_camera_shake_requested)
	# Set position smoothing to false initially
	position_smoothing_enabled = false
	
	# Create a timer to enable smoothing after 1 second
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(_enable_smoothing)

func _enable_smoothing() -> void:
	position_smoothing_enabled = true

func _on_camera_shake_requested(strength: float, duration: float) -> void:
	shake_camera(strength, duration)

func shake_camera(shake_strength: float = 30.0, shake_duration: float = 0.2) -> void:
	var shake_tween = create_tween()
	for i in range(10):
		var rand_offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_tween.tween_property(
			self,
			"offset",
			rand_offset,
			shake_duration / 10
		).set_ease(Tween.EASE_IN_OUT)
	
	# 最后回到原位
	shake_tween.tween_property(
		self,
		"offset",
		Vector2.ZERO,
		shake_duration / 10
	)	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#limit_left = floor($"..".global_position.x / camera_h) * camera_h
	#limit_right = limit_left + camera_h + grid_size
	#
	#limit_top = floor($"..".global_position.y / camera_v) * camera_v
	#limit_bottom = limit_top + camera_v + grid_size
	pass
