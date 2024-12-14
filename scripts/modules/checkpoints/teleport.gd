extends Area2D

enum TeleportType {DAY2DREAM,DREAM2DAY,DREAM2DREAM} 

@export var teleport_time: float = 0.9
@export var target_scene: String = "res://scenes/day/game/game.tscn"
@export var teleport_type: TeleportType = TeleportType.DREAM2DAY
@export var transition_scene: String = "res://scenes/modules/checkpoints/transition.tscn"  # 添加过渡场景路径



@onready var timer: Timer = Timer.new() #teleport_time
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	GameManager.game_state_cache['do_detect_teleport'] = true
	# 添加计时器
	add_child(timer)
	timer.wait_time = teleport_time
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

	var original_color = animated_sprite_2d.modulate
	# 调整为偏红色
	var red_tint = Color(1.0, 0.4, 0.4, 1.0)  # 使用较高的红色值，较低的绿色和蓝色值
	var inverted_color = Color(1, 1, 1, 1) - original_color + Color(0, 0, 0, 1)
	animated_sprite_2d.modulate = inverted_color.blend(red_tint)


func _on_body_entered(body: CharacterBody2D) -> void:
	if body is CharacterBody2D and GameManager.game_state_cache['do_detect_teleport']:
		GameManager.game_state_cache['do_detect_teleport'] = false
		timer.start()
		audio_player.play()
	

func _on_timer_timeout():
	# 创建过渡场景实例
	GameManager.game_state['target_scene'] = target_scene
	if teleport_type == TeleportType.DAY2DREAM:
		GameManager.game_state['teleport_type'] = 'day2dream'
	elif teleport_type == TeleportType.DREAM2DAY:
		GameManager.game_state['teleport_type'] = 'dream2day'
	elif teleport_type == TeleportType.DREAM2DREAM:
		GameManager.game_state['teleport_type'] = 'dream2dream'
	GameManager.save_game_state()
	GameManager.game_state_cache['do_detect_teleport'] = true
	get_tree().change_scene_to_file(transition_scene)
