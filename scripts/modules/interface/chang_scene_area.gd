extends Area2D

var do_detect: bool = true
var timer: Timer
var timer2: Timer
var timer3: Timer
var timer4: Timer
var player: Node2D
var fade_overlay: ColorRect
var canvas_layer: CanvasLayer

@export var next_scene_file_path: String
@export var teleport_type: String = 'day2dream'
@export var time_scale: float = 5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	player = get_tree().get_first_node_in_group("player")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not do_detect:
		return

	do_detect = false
	GameManager.game_state_cache['should_die'] = false
	GameManager.game_state['target_scene'] = next_scene_file_path
	GameManager.game_state['teleport_type'] = teleport_type
	# await get_tree().create_timer(0.1).timeout
	# player.set_can_move(false,'idle')
