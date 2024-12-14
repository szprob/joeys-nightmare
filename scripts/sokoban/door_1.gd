extends StaticBody2D

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@export var is_keep_open: bool = false
@export var keep_open_duration: float = 2.0 # Duration in seconds to keep the door open

var is_open = false
var auto_close_timer: Timer
var is_timer_running = false # New variable to track timer state

func _ready():
	# Create and configure the timer
	auto_close_timer = Timer.new()
	auto_close_timer.one_shot = true
	auto_close_timer.timeout.connect(_on_timer_timeout)
	add_child(auto_close_timer)

func open():
	if not is_open:
		is_open = true
		self.set_collision_layer(0)
		animated_sprite.play()
		audio_player.play()
		
		if is_keep_open:
			is_timer_running = true # Set timer state
			auto_close_timer.start(keep_open_duration)

func close():
	# Only close if the door is open and timer is not running
	if is_open and not is_timer_running:
		is_open = false
		self.set_collision_layer(1)
		animated_sprite.play_backwards()
		audio_player.play()

func _on_timer_timeout():
	is_timer_running = false # Reset timer state
	close()
