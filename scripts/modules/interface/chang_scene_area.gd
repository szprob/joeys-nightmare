extends Area2D

var do_detect: bool = true
var timer: Timer
var timer2: Timer
var timer3: Timer
var player: Node2D

@export var next_scene_file_path: String
@export var teleport_type: String = 'day2dream'
@export var time_scale: float = 5
@export var transition_scene: String = "res://scenes/modules/checkpoints/transition.tscn"  # 添加过渡场景路径

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	player = get_tree().get_first_node_in_group("player")
	GameManager.die_requested.connect(_on_die_requested)
	body_entered.connect(_on_body_entered)
	timer = Timer.new()
	timer.wait_time = time_scale
	timer.timeout.connect(_on_timeout)
	add_child(timer)
	timer2 = Timer.new()
	timer2.wait_time = time_scale
	timer2.timeout.connect(_on_timeout2)
	add_child(timer2)
	timer3 = Timer.new()
	timer3.wait_time = 1
	timer3.timeout.connect(_on_timeout3)
	add_child(timer3)



func _on_timeout() -> void:
	player.set_can_move(false,'idle')
	timer2.start()

func _on_timeout2() -> void:
	finish()


func _on_die_requested() -> void:
	finish()

func _on_timeout3() -> void:
	GameManager.game_state['target_scene'] = next_scene_file_path
	GameManager.game_state['teleport_type'] = teleport_type
	# GameManager.save_game_state()
	get_tree().change_scene_to_file(transition_scene)

func finish() -> void:
	timer3.start()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not do_detect:
		return
	do_detect = false
	GameManager.game_state_cache['should_die'] = false
	timer.start()
