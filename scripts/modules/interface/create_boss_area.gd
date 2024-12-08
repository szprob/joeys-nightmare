extends Area2D

var do_detect: bool = true

var timer: Timer # 动画
@export var timer1_scale: float = 1

var timer2: Timer # audio 
@export var timer2_scale: float = 0.8

var timer3: Timer # finish
@export var timer3_scale: float = 0.8

var player: Node2D


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	player = get_tree().get_first_node_in_group("player")

	animated_sprite.visible = false

	body_entered.connect(_on_body_entered)
	timer = Timer.new()
	timer.wait_time = timer1_scale
	timer.timeout.connect(_on_timeout)
	add_child(timer)

	timer2 = Timer.new()
	timer2.wait_time = timer2_scale
	timer2.timeout.connect(_on_timeout2)
	add_child(timer2)

	# timer3 = Timer.new()
	# timer3.wait_time = timer3_scale
	# timer3.timeout.connect(_on_timeout3)
	# add_child(timer3)

func _on_timeout() -> void:
	# animated_area.visible = true
	animated_sprite.visible = true
	animated_sprite.play("default")
	timer2.start()


func _on_timeout2() -> void:
	audio_player.play()
	






func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not do_detect:
		return
	do_detect = false
	await get_tree().create_timer(0.1).timeout
	player.set_can_move(false,'idle')
	timer.start()
