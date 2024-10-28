extends CharacterBody2D

@export var speed = 250
var direction = Vector2(0, 0) # 默认方向


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func start(pos, shoot_direction):
	print(shoot_direction)
	position = pos
	
	shoot_direction = shoot_direction.normalized()
	direction = shoot_direction


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var bullet_collision = move_and_collide(speed * direction * delta)
	if bullet_collision: # 首先检查是否发生碰撞
		var collider = bullet_collision.get_collider() # 获取碰撞对象
		if collider is TileMapLayer or collider is StaticBody2D: # 检查碰撞对象是否为 TileMaplayer
			print('碰撞到地图')
			var collision_normal = bullet_collision.get_normal()
			var gravity_scene = preload("res://scenes/sokoban/gravity_1.tscn")
			
			var gravity_instance = gravity_scene.instantiate()
			gravity_instance.add_to_group("dynamic")
			
			gravity_instance.position = position + collision_normal * Vector2(gravity_instance.get_node("CollisionShape2D").shape.get_size().x / 2, gravity_instance.get_node("CollisionShape2D").shape.get_size().y / 2)
			collision_normal.y = collision_normal.y * -1
			collision_normal.x = collision_normal.x * -1
			gravity_instance.gravity_direction = collision_normal
			#
			print('gravity instance', gravity_instance)
			print('gravity instance meta', gravity_instance.get_meta_list())
			get_tree().root.add_child(gravity_instance)

			queue_free() # 销毁子弹

#func _on_area_entered(area: Area2D) -> void:
	#if area is TileMapLayer:
		#print('hit tilemap, add a gravity area')
		
		
func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#print(body.name)
	#if body is TileMapLayer:
		## 获取碰撞状态
		#var space_state = get_world_2d().direct_space_state
		## 创建射线查询参数
		#var query = PhysicsRayQueryParameters2D.create(
			#position, 
			#position + direction * 10  # 从当前位置向运动方向射出一条短射线
		#)
		## 执行射线检测
		#var result = space_state.intersect_ray(query)
		#
		#if result:
			#var collision_normal = result.normal
			#print('碰撞法线方向: ', collision_normal)
			#
			## 实例化gravity节点
			#var gravity_scene = preload("res://scenes/sokoban/gravity_1.tscn")
			#var gravity_instance = gravity_scene.instantiate()
			#
			#gravity_instance.position = position + collision_normal * Vector2(0, gravity_instance.get_node("CollisionShape2D").shape.get_size().y/2)
			#gravity_instance.gravity_direction = collision_normal
			#
			#get_tree().root.add_child(gravity_instance)
			#queue_free()
	pass

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
