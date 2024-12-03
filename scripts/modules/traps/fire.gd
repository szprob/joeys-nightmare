extends AnimatableBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	pass
	# if animated_sprite.sprite_frames:
	# 	var total_frames = animated_sprite.sprite_frames.get_frame_count(animated_sprite.animation)
	# 	var random_start_frame = randi() % total_frames
	# 	animated_sprite.frame = random_start_frame
	# 	animated_sprite.play()
		
