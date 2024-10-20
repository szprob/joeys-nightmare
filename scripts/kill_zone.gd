extends Area2D

@onready var timer: Timer = $Timer
@onready var game_manager: Node = %game_manager


# 保存对玩家的引用
var player: CharacterBody2D = null
var respawn_protection_time = 1.0 # 无敌时间（秒）


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("die!!")
		Engine.time_scale = 0.5 
		player = body # 保存对玩家的引用
		var collision_shape = player.get_node("CollisionShape2D")
		collision_shape.set_deferred("disabled", true) # 暂时禁用碰撞形状
		set_deferred("monitoring", false)
		#body.get_node("CollisionShape2D").queue_free()
		timer.start()
	


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	if player:
		# 立即将玩家移出 kill zone 的范围
		player.respawn()
		# 恢复玩家的碰撞形状
		var collision_shape = player.get_node("CollisionShape2D")
		collision_shape.set_deferred("disabled", false)

		player = null
	else:
		# 使用 await 等待无敌时间结束
		await get_tree().create_timer(respawn_protection_time).timeout
		# 恢复 kill zone 的检测
		set_deferred("monitoring", true)
	#get_tree().reload_current_scene()
