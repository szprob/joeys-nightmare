extends Area2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var collected: bool = false  # 防止重复触发

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return  # 如果已经收集过，直接返回
	#print(GameManager.game_state['score'])
	collected = true  # 标记为已经收集

	#GameManager.game_state['score'] += 1 

	# 创建一个新的节点来播放音效
	var temp_audio_player = AudioStreamPlayer2D.new()
	temp_audio_player.stream = audio_stream_player_2d.stream
	temp_audio_player.global_position = global_position  # 确保音效在硬币的位置播放
	get_parent().add_child(temp_audio_player)  # 添加到场景树中
	temp_audio_player.play()

	# 音效播放结束后自动清理节点
	temp_audio_player.connect("finished", Callable(temp_audio_player, "queue_free"))

	# 立即销毁硬币
	queue_free()
