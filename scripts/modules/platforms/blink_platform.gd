extends AnimatableBody2D

var is_visible = true

@export var init_time_delay: float = 1
@export var blink_gap: float = 1

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer: Timer = Timer.new() #启动时间
@onready var timer_2: Timer = Timer.new() #闪烁间隔


func _ready() -> void:
	timer.wait_time = init_time_delay
	timer_2.wait_time = blink_gap
	timer.one_shot = true
	timer_2.one_shot = false
	add_child(timer)
	add_child(timer_2)
	timer.timeout.connect(_on_timer_timeout)
	timer_2.timeout.connect(_on_timer_2_timeout)
	timer.start()
		

func _on_timer_timeout() -> void:
	timer_2.start()  # Start the blinking timer


func _on_timer_2_timeout() -> void:
	is_visible = !is_visible
	sprite_2d.visible = is_visible
	collision_shape_2d.disabled = !is_visible

	