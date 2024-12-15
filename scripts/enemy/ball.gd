extends Area2D

@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var kill_zone_collision: CollisionShape2D = $kill_zone/CollisionShape2D
@export var move_speed: float = 200.0

enum State {
	MOVING,
	EXPLODE
}
var state = State.MOVING
var target_position = Vector2.ZERO
var origin_scale_x
var do_detect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	do_detect = true
	body_entered.connect(_on_body_entered)
	origin_scale_x = scale.x

func _on_body_entered(_body: Node2D) -> void:
	if do_detect:
		do_detect = false
		state = State.EXPLODE
		explode()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		State.MOVING:
			var move_direction = (target_position - global_position).normalized()
			global_position += move_direction * move_speed * delta
			if global_position.distance_to(target_position) < 10:
				state = State.EXPLODE
				explode()



func explode():
	audio_stream_player.play(0.7)
	animated_sprite.play("explode")
	kill_zone_collision.disabled = true
	await animated_sprite.animation_finished
	visible = false
	
	

func set_target(target: Node2D):
	target_position = target.global_position
	state = State.MOVING
	var move_direction = (target_position - global_position).normalized()
	# scale.x = origin_scale_x if direction.x > 0 else -origin_scale_x
	rotation = move_direction.angle()
