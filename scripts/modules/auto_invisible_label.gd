extends Label

@export var time_to_fade: float = 4.0
@export var fade_duration: float = 3.0

@onready var timer: Timer = Timer.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = time_to_fade
	timer.timeout.connect(_on_timer_timeout)
	timer.start()



func _on_timer_timeout() -> void:
	# 创建渐隐动画
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	# 动画结束后隐藏Label
	await tween.finished
	visible = false


