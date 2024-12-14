extends StaticBody2D

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_open = false

func open():
	if not is_open:
		print('open door')
		is_open=true
		self.set_collision_layer(0)
		animated_sprite.play()
		audio_player.play()

func close():
	if is_open:
		print('close door')
		is_open=false
		self.set_collision_layer(1)
		animated_sprite.play_backwards()
		audio_player.play()
