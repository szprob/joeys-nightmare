extends Area2D


var player_in_range: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var door_name: String = '城堡第一个门'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible = false
	# 绑定进入信号
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group('player'):
		player_in_range = true
		label.visible = true


func _on_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group('player'):
		player_in_range = false
		label.visible = false


func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("select"):
		# 播放音效
		if audio_player:
			audio_player.play()
		# 执行开门逻辑
		GameManager.game_state['doors_opened'].append(door_name)
		collision_shape.disabled = true
		sprite.visible = false
		label.visible = false
