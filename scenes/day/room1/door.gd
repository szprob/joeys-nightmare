extends Sprite2D

@onready var audio_player: AudioStreamPlayer2D = $door_audio

var audio_finished: bool = false

func _ready() -> void:
	if GameManager.game_state['is_door_open']:
		queue_free()
	audio_player.connect("finished", _on_AudioStreamPlayer_finished)

func _process(delta: float) -> void:
	if GameManager.is_door_open() and not audio_player.is_playing():
		audio_player.play()

func _on_AudioStreamPlayer_finished():
	queue_free()
