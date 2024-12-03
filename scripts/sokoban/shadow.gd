extends Sprite2D

var fade_speed = 1

func _ready():
	modulate.a = 0.5 # 初始透明度

func _process(delta):
	modulate.a -= fade_speed * delta
	if modulate.a <= 0:
		queue_free()
