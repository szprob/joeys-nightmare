extends Area2D

@export var teleport_time: float = 1.0
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var target: Area2D = $target
@onready var timer: Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 添加计时器
	add_child(timer)
	timer.wait_time = teleport_time
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
	# 建立信号连接
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and GameManager.game_state['teleport_tgt_enable']:
 		body.global_position = target.global_position
		GameManager.game_state['teleport_tgt_enable'] = false
		timer.start()


func _on_timer_timeout() -> void:
	GameManager.game_state['teleport_tgt_enable'] = true
