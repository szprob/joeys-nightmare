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


func _on_timer_2_timeout() -> void:
	queue_free()

func start_blinking() -> void:
	var blink_animation = Animation.new()
	blink_animation.length = blink_time
	blink_animation.set_loop_mode(1)

	var track_index = blink_animation.add_track(Animation.TYPE_VALUE)
	blink_animation.track_set_path(track_index, "Sprite2D:visible")
	
	for i in range(0, int(blink_time * 2)):
		var time = i * 0.5
		var value = i % 2 == 0
		blink_animation.track_insert_key(track_index, time, value)

	animation_player.add_animation("blink", blink_animation)
	animation_player.play("blink")
