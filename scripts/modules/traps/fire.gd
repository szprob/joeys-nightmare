extends AnimatableBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
		
	if animated_sprite.sprite_frames:
		var total_frames = animated_sprite.sprite_frames.get_frame_count(animated_sprite.animation)
		var random_start_frame = randi() % total_frames
		animated_sprite.frame = random_start_frame
		animated_sprite.play()
		
	# 获取父节点的clockwise变量
	var parent = get_parent()
	var is_clockwise = parent.get("clockwise")
	if animated_sprite:
		animated_sprite.flip_h = not is_clockwise
