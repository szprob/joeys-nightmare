extends StaticBody2D

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_open = false

func open():
	if not is_open:
		print('open door')
		is_open=true
		collision_shape.disabled=true
		animated_sprite.play()
		audio_player.play()

func close():
	if is_open:
		print('close door')
		is_open=false
		collision_shape.disabled=false
		animated_sprite.play_backwards()
		audio_player.play()
