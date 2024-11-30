extends Area2D

var can_die: bool = true

@onready var timer: Timer = $Timer

# for 死亡动画
@onready var death_effect: ColorRect = $CanvasLayer/DeathEffect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	Engine.time_scale = 1
	death_effect.visible = false
	death_effect.color = Color(1, 1, 1, 0)
	death_effect.set_anchors_preset(Control.PRESET_FULL_RECT)
	# 确保 ColorRect 显示在最上层
	death_effect.z_index = 100

func _on_body_entered(body: Node2D) -> void:
	if not GameManager.game_state['can_detect_kill_zone']:
		return
	print("die!!")
	GameManager.game_state['can_detect_kill_zone'] = false
	Engine.time_scale = 0.5
	# if body.has_method("respawn"):
	# 	body.respawn()
	death_effect.visible = true
	animation_player.play("death_effect")
	timer.start()
	

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	GameManager.game_state['can_detect_kill_zone'] = true
	death_effect.visible = false
	# var root_node = get_tree().get_root()
	var root_node = get_tree().current_scene
	cleanup_dynamic_nodes()
	get_tree().change_scene_to_file(root_node.scene_file_path)


func cleanup_dynamic_nodes() -> void:
	# 假设你给所有动态添加的节点都加了一个组名
	var dynamic_nodes = get_tree().get_nodes_in_group("dynamic")
	for node in dynamic_nodes:
		node.queue_free()
