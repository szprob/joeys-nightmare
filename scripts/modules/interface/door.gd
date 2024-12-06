extends Area2D


var player_in_range: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D #open
@onready var audio_player2: AudioStreamPlayer2D = $AudioStreamPlayer2D2 #locked
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var area: StaticBody2D = $StaticBody2D

@export var door_name: String = '城堡第一个门'
@export var key_name_need: String = '彩色钥匙1'
enum DoorColor {
	RED,
	YELLOW,
	BLUE
}
@export var door_color: DoorColor = DoorColor.RED # 导出颜色属性


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if door_name in GameManager.game_state['doors_opened']:
		queue_free()

	label.visible = false
	# 根据颜色加载相应的sprite
	match door_color:
		DoorColor.RED:
			sprite.texture = preload("res://assets/sprites/modules/pillar_r.png")
		DoorColor.YELLOW:
			sprite.texture = preload("res://assets/sprites/modules/pillar_y.png")
		DoorColor.BLUE:
			sprite.texture = preload("res://assets/sprites/modules/pillar_b.png")
	# 绑定进入信号
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group('player'):
		player_in_range = true


func _on_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group('player'):
		player_in_range = false


func _process(_delta: float) -> void:
	if player_in_range:
		label.visible = true
	else:
		label.visible = false


	if player_in_range and Input.is_action_just_pressed("select"):
		# 检查钥匙是否在背包中
		if key_name_need in GameManager.game_state['inventory']:
			# 播放开门音效
			if audio_player:
				audio_player.play()
			# 执行开门逻辑
			GameManager.game_state['doors_opened'].append(door_name)
			collision_shape.disabled = true
			if area:
				area.queue_free()
			sprite.visible = false
			label.visible = false
		else:
			# 播放锁住音效
			if audio_player2:
				audio_player2.play()
			# 添加振动效果
			var tween = create_tween()
			tween.tween_property(sprite, "position:x", sprite.position.x + 2, 0.1)
			tween.tween_property(sprite, "position:x", sprite.position.x - 2, 0.1)
			tween.tween_property(sprite, "position:x", sprite.position.x + 2, 0.1)
			tween.tween_property(sprite, "position:x", sprite.position.x, 0.1)
