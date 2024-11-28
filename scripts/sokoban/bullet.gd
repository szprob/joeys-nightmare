extends CharacterBody2D

@export var max_distance = 16 * 2 # 最大检测距离
@export var speed = 250
var direction = Vector2(0, 0) # 默认方向


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func start(pos, shoot_direction):
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
			var shape = RectangleShape2D.new() # 创建新的形状实例
			gravity_instance.get_node("CollisionShape2D").shape = shape
			var perpendicular = Vector2(-collision_normal.y, collision_normal.x)
			
			# 获取碰撞点位置，而不是使用子弹的位置
			var collision_point = bullet_collision.get_position()
			
			# 使用碰撞点进行射线检测
			var space_state = get_world_2d().direct_space_state
			var distance_positive = cast_ray(space_state, collision_point, perpendicular, collision_normal)
			var distance_negative = cast_ray(space_state, collision_point, -perpendicular, collision_normal)
			
			var gravity_shape = gravity_instance.get_node("CollisionShape2D").shape
			var fixed_length = 32
			# print('collision_point', collision_point)
			# print('distance_positive', distance_positive)
			# print('distance_negative', distance_negative)
			if abs(collision_normal.x) > 0: # 水平方向打子弹
				# gravity_shape.size = Vector2(distance_positive + distance_negative, fixed_length)
				gravity_shape.size = Vector2(fixed_length, distance_positive + distance_negative)
				gravity_instance.position = collision_point + collision_normal * (fixed_length / 2) + Vector2(0, collision_normal.x * (distance_positive - distance_negative) / 2)
			else:
				gravity_shape.size = Vector2(distance_positive + distance_negative, fixed_length)
				gravity_instance.position = collision_point + collision_normal * (fixed_length / 2) - Vector2((distance_positive - distance_negative) / 2, 0)
			
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
			var player = get_tree().get_first_node_in_group("player") # 确保player加入了"player"组
			if player and player.has_method("add_gravity_field"):
				player.add_gravity_field(gravity_instance)
			queue_free()
		elif collider is CharacterBody2D:
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

func cast_ray(space_state: PhysicsDirectSpaceState2D, from: Vector2, direction: Vector2, collision_normal: Vector2) -> float:
	
	# 根据射线方向添加适当的偏移
	var offset = 2.0 # 偏移量
	var adjusted_from = from
	
	# 如果射线方向是水平的，添加垂直偏移
	if abs(direction.x) > 0.9: # 接近水平方向
		# adjusted_from = Vector2(0, offset)
		adjusted_from += Vector2(0, collision_normal.y * offset)
	# 如果射线方向是垂直的，添加水平偏移
	elif abs(direction.y) > 0.9: # 接近垂直方向
		adjusted_from += Vector2(collision_normal.x * offset, 0)
	
	print('adjusted_from', adjusted_from)

	var query = PhysicsRayQueryParameters2D.create(
		adjusted_from,
		adjusted_from + direction * max_distance
	)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	if result:
		var collider = result.collider
		while collider != null:
			if collider is TileMapLayer:
				return (result.position - from).length()
			collider = collider.get_parent()
	return max_distance
