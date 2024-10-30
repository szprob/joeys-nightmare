extends AnimatableBody2D


var do_detect = true 

@export var init_time_delay: float = 1
@export var blink_time: float = 3
@export var blink_gap: float = 0.5


@onready var timer: Timer = Timer.new()
@onready var timer_2: Timer = Timer.new()
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = AnimationPlayer.new()

func _ready() -> void:
	timer.wait_time = init_time_delay
	timer_2.wait_time = blink_time
	timer.one_shot = true
	timer_2.one_shot = true
	add_child(timer)
	add_child(timer_2)
	add_child(animation_player)
	timer.timeout.connect(_on_timer_timeout)
	timer_2.timeout.connect(_on_timer_2_timeout)

func _on_detection_body_entered(body: Node2D) -> void:
	if do_detect:
		if body is CharacterBody2D:
			do_detect=false
			timer.start()


func _on_timer_timeout() -> void:
	timer_2.start()
	start_blinking()
	print("开始闪烁")



func _on_timer_2_timeout() -> void:
	print("准备消失")
	animation_player.stop()
	sprite_2d.modulate.a = 0
	collision_shape_2d.set_deferred("disabled", true)
	queue_free()

func start_blinking() -> void:
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "Sprite2D:modulate")
	animation.length = blink_gap
	
	animation.track_insert_key(track_index, 0, Color(1, 1, 1, 1))
	animation.track_insert_key(track_index, blink_gap/2, Color(1, 1, 1, 0))
	animation.track_insert_key(track_index, blink_gap, Color(1, 1, 1, 1))
	
	animation.loop_mode = Animation.LOOP_LINEAR
	
	animation_player.add_animation_library("", AnimationLibrary.new())
	animation_player.get_animation_library("").add_animation("blink", animation)
	animation_player.play("blink")