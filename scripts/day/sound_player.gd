extends Node2D

@onready var sound_player: AudioStreamPlayer2D = $sound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func play_sound(sound_path: String, loop: bool = false) -> void:
	if ResourceLoader.exists(sound_path):
		var sound_stream = ResourceLoader.load(sound_path)
		if loop:
			if sound_stream is AudioStreamMP3:
				sound_stream.loop = loop
			elif sound_stream is AudioStreamWAV:
				sound_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		# sound_player.stream = load(sound_path)
		sound_player.stream = sound_stream
		sound_player.play()

func stop_sound() -> void:
	if sound_player.playing:
		sound_player.stop()
