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
	if bullet_collision:
		var collider = bullet_collision.get_collider()
		if collider is TileMapLayer or collider is StaticBody2D:
			var collision_normal = bullet_collision.get_normal()
			var gravity_scene = preload("res://scenes/sokoban/gravity_1.tscn")
			
			var gravity_instance = gravity_scene.instantiate()
			gravity_instance.add_to_group("dynamic")
			
			var perpendicular = Vector2(-collision_normal.y, collision_normal.x)
			
			# 获取碰撞点位置，而不是使用子弹的位置
			var collision_point = bullet_collision.get_position()
			
			# 使用碰撞点进行射线检测
			var space_state = get_world_2d().direct_space_state
			var distance_positive = cast_ray(space_state, collision_point, perpendicular)
			var distance_negative = cast_ray(space_state, collision_point, -perpendicular)
			
			var gravity_shape = gravity_instance.get_node("CollisionShape2D").shape
			var fixed_length = 32
			print('collision_point', collision_point)
			print('distance_positive', distance_positive)
			print('distance_negative', distance_negative)
			if abs(collision_normal.x) > 0:
				gravity_shape.size = Vector2(distance_positive + distance_negative, fixed_length)
				gravity_instance.position = collision_point - Vector2(8, 0)
			else:
				gravity_shape.size = Vector2(distance_positive + distance_negative, fixed_length)
				gravity_instance.position = collision_point + collision_normal * (fixed_length / 2)
			
			collision_normal.y *= -1
			collision_normal.x *= -1
			gravity_instance.gravity_direction = collision_normal
			
			# 将重力区域添加到专门的容器节点中
			var gravity_container = get_tree().get_root().get_node_or_null("GravityContainer")
			if not gravity_container:
				gravity_container = Node2D.new()
				gravity_container.name = "GravityContainer"
				get_tree().get_root().add_child(gravity_container)
			
			gravity_container.add_child(gravity_instance)
			queue_free()

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

func cast_ray(space_state: PhysicsDirectSpaceState2D, from: Vector2, direction: Vector2) -> float:
	var max_distance = 1000 # 最大检测距离
	var query = PhysicsRayQueryParameters2D.create(
		from,
		from + direction * max_distance
	)
	# print('from', from)
	from = from + Vector2(2, 0)
	print('direction', direction)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	# print('query', query)
	
	var result = space_state.intersect_ray(query)
	print('result', result.collider)
	print('result.position', result.position)
	if result:
		var collider = result.collider
		while collider != null:
			if collider is TileMapLayer:
				# print('hit something')
				# print('result', result)
				return (result.position - from).length()
			collider = collider.get_parent()
	return max_distance
