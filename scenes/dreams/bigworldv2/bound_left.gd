extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# 定义 on_body_entered 函数
func on_body_entered(body):
	if body.is_in_group("player"):
		# 添加振动效果
		GameManager.camera_shake_requested.emit(5, 0.2)
		# 给玩家一个反向作用力
		if body.has_method("apply_force"):
			var collision_direction = (body.global_position - global_position).normalized()
			body.apply_force(collision_direction * 1000)
			body.set_can_move(false,'jump')
