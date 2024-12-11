extends Area2D

@onready var sprite = $AnimatedSprite2D  # 假设你有一个 AnimatedSprite2D 子节点

func _ready() -> void:
	# 确保有动画精灵节点
	if sprite:
		# 获取动画总帧数
		var frames_count = sprite.sprite_frames.get_frame_count("poison2")
		# 设置随机起始帧
		sprite.frame = randi() % frames_count

		sprite.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
