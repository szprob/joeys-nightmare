extends Area2D

var timer: Timer
var do_detect: bool = true

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $Label
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite: Sprite2D = $Sprite2D

@export var key_name: String = "彩色钥匙"
@export var disappear_delay: float = 3
enum KeyColor {
	RED,
	YELLOW,
	BLUE
}
@export var key_color: KeyColor = KeyColor.RED # 导出颜色属性


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.has_item(key_name):
		queue_free()

	# 绑定进入信号
	body_entered.connect(_on_body_entered)
	# label 
	label.text = '获得了%s' % key_name
	# label.add_theme_font_size_override("font_size", 11)
	label.visible = false
	# timer 
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = disappear_delay
	# timer.start()
	match key_color:
		KeyColor.RED:
			sprite.texture = preload("res://assets/sprites/modules/key_r.png")
		KeyColor.YELLOW:
			sprite.texture = preload("res://assets/sprites/modules/key_y.png")
		KeyColor.BLUE:
			sprite.texture = preload("res://assets/sprites/modules/key_b.png")




func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group('player') and do_detect:
		GameManager.add_item(key_name)
		label.visible = true
		do_detect = false
		if audio_player:
			audio_player.play()
		timer.start()
		# 创建上升消失的动画
		var tween = create_tween()
		tween.set_parallel(true)  # 允许同时执行多个动画
		# 只对sprite应用动画效果
		tween.tween_property(sprite, "position:y", sprite.position.y - 50, 0.5)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
		# 动画完成后删除整个节点
		await tween.finished
		sprite.queue_free()
		
func _on_timer_timeout() -> void:
	queue_free()

