extends Node2D

@export var intro_camera: Camera2D # 专门用于开场动画的相机
@export var player_camera: Camera2D # 假设这是角色相机的路径
@onready var monster = $Monster
var is_camera_panning := false
var start_position: Vector2
var target_position: Vector2
var pan_duration := 4.0
var pan_timer := 0.0

static var intro_played := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.game_state_cache['should_die'] = true
	if not GameManager.game_state_cache['bmg_set']:
		GameManager.setup_bgm_player()
	GameManager.play_bgm('chase')

	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if not intro_played:
		setup_intro_camera()
		start_camera_pan()
		intro_played = true
	else:
		monster.init_wait_time = 1.5
		player_camera.enabled = true
		intro_camera.enabled = false

func setup_intro_camera() -> void:
	# 暂时禁用角色相机
	player_camera.enabled = false
	# 启用介绍相机
	intro_camera.enabled = true
	intro_camera.make_current()

func _process(delta: float) -> void:
	if is_camera_panning:
		pan_timer += delta
		var t = pan_timer / pan_duration
		if t >= 1.0:
			finish_camera_pan()
		else:
			var weight = smoothstep(0.0, 1.0, t)
			intro_camera.position = start_position.lerp(target_position, weight)

func start_camera_pan() -> void:
	is_camera_panning = true
	pan_timer = 0.0
	start_position = Vector2(1300, player_camera.global_position.y * 2 + 24) # 起始位置
	target_position = Vector2(player_camera.global_position.x+128, player_camera.global_position.y * 2 + 24) # 目标位置
	intro_camera.position = start_position
	get_tree().paused = true

func finish_camera_pan() -> void:
	is_camera_panning = false
	intro_camera.position = target_position

	var tween = create_tween()
	tween.tween_callback(func():
		intro_camera.enabled = false
		player_camera.enabled = true
	).set_delay(0.5) # 可以调整延迟时间

	get_tree().paused = false
