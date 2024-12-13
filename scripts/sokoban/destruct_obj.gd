extends RigidBody2D
#
@export_range(2, 10, 2) var blocks_per_side = 6
@export var blocks_impulse: float = 600
@export var blocks_gravity_scale: float = 10
@export var debris_max_time: float = 5
@export var remove_debris: bool = false
@export var collision_layers: int = 1
@export var collision_masks: int = 1
@export var collision_one_way: bool = false
@export var explosion_delay: bool = false
@export var fake_explosions_group: String = "fake_explosion_particles"
@export var randomize_seed: bool = false
@export var debug_mode: bool = true
@export var trigger_path = '../Trigger'
@export var trigger_node_name: String = "Trigger"
@export var node_to_explode: Node2D
# @export var tilemap_to_explode: TileMapLayer

# var object = DestructObject.new()

var explosion_delay_timer = 0
var explosion_delay_timer_limit = 0
var _initialization_complete: bool = false
# var object: DestructObject.new()
var _debug_printed: bool = false
var explosion_detector: Area2D


# var params = {
# 		"blocks_gravity_scale": blocks_gravity_scale,
# 		"blocks_impulse": blocks_impulse,
# 		"blocks_per_side": blocks_per_side,
# 		"collision_layers": collision_layers,
# 		"collision_masks": collision_masks,
# 		"collision_one_way": collision_one_way,
# 		"debris_max_time": debris_max_time,
# 		"remove_debris": remove_debris,
# 		"parent": get_parent()
# 	}
var object

class DestructObject:
	var blocks: Array[Node] = []
	var blocks_container: Node2D
	var blocks_gravity_scale: float
	var blocks_impulse: float
	var blocks_per_side: int
	var can_detonate: bool = true
	var collision_extents: Vector2
	var collision_layers: int
	var collision_masks: int
	var collision_name: String
	var collision_one_way: bool
	var collision_position: Vector2
	var debris_max_time: float
	var debris_timer: Timer
	var detonate: bool = false
	var frame: int = 0
	var has_detonated: bool = false
	var has_particles: bool = false
	var height: float = 0
	var hframes: int = 1
	var offset: Vector2
	var parent: Node
	var particles: Node
	var remove_debris: bool
	var sprite_name: String
	var vframes: int = 1
	var width: float = 0

	func _init(params: Dictionary) -> void:
		blocks_container = Node2D.new()
		blocks_gravity_scale = params.get("blocks_gravity_scale", 1.0)
		blocks_impulse = params.get("blocks_impulse", 600.0)
		blocks_per_side = params.get("blocks_per_side", 6)
		collision_layers = params.get("collision_layers", 1)
		collision_masks = params.get("collision_masks", 7)
		collision_one_way = params.get("collision_one_way", false)
		debris_max_time = params.get("debris_max_time", 5.0)
		remove_debris = params.get("remove_debris", false)
		parent = params.get("parent")
		debris_timer = Timer.new()


func _ready():
	# print("Script is running, debug_mode is: ", debug_mode)
	# if debug_mode:
	# 	print("My collision layer: ", collision_layer)
	# 	print("My collision mask: ", collision_mask)
	# 	print("Can detect static bodies: ", collision_mask & 1)
	# print('node_to_explode: ', node_to_explode.name)
	# print('self name: ', self.name)
	# print('tilemap_to_explode: ', tilemap_to_explode.name)
	var params = {
		"blocks_gravity_scale": blocks_gravity_scale,
		"blocks_impulse": blocks_impulse,
		"blocks_per_side": blocks_per_side,
		"collision_layers": collision_layers,
		"collision_masks": collision_masks,
		"collision_one_way": collision_one_way,
		"debris_max_time": debris_max_time,
		"remove_debris": remove_debris,
		"parent": get_parent()
	}
	object = DestructObject.new(params)

	explosion_detector = get_parent().get_node(trigger_node_name)
	#explosion_detector = get_node(trigger_path)
	if explosion_detector:
		explosion_detector.set_collision_layer_value(1, false)
		explosion_detector.set_collision_mask_value(7, true)
		# print('detector found')
		explosion_detector.area_entered.connect(_on_trigger_entered)
		explosion_detector.body_entered.connect(_on_trigger_entered)
		# print('connected explosion_detector', explosion_detector.name)
		# print('detector collision_mask: ', explosion_detector.collision_mask)

	# 连接区域进入信号
	
	# explosion_detector.area_entered.connect(_on_area_area_entered)

	if _initialization_complete:
		return

	# 2. 更严格的块检查
	if "_block_" in self.name:
		# 这是一个复制出来的块，不应该再次执行初始化
		return
		
	# 3. 添加调试日志
	if debug_mode:
		print("Starting initialization for: ", self.name)

	if debug_mode:
		print("Current node: ", self.name)
		print("Parent node: ", get_parent().name if get_parent() else "No parent")
		print("Scene tree valid: ", is_inside_tree())

	object.parent = get_parent()
	# Add a unique name to 'blocks_container'.
	object.blocks_container.name = self.name + "_blocks_container"

	# Randomize the seed of the random number generator.
	if randomize_seed: randomize()

	if not is_instance_of(self, RigidBody2D):
		print("ERROR: The '%s' node must be a 'RigidBody2D'" % self.name)
		object.can_detonate = false
		return
	# print('node_to_explode', node_to_explode)
	# print('node_to_explode: ', node_to_explode.name)
	## deal with if into a tilemap to explode
	for child in node_to_explode.get_children():
		if is_instance_of(child, Sprite2D):
			object.sprite_name = child.name
			var sprite_copy = child.duplicate()
			add_child(sprite_copy)
			child.queue_free()

		if child is CollisionShape2D:
			object.collision_name = child.name
			var collision_copy = child.duplicate()
			add_child(collision_copy)
			child.queue_free()
			
	if not object.sprite_name and not object.collision_name:
		print("ERROR: The 'RigidBody2D' (%s) must contain at least a 'Sprite' and a 'CollisionShape2D'." % self.name)
		object.can_detonate = false
		return

	if object.blocks_per_side > 10:
		print("ERROR: Too many blocks in '%s'! The maximum is 10 blocks per side." % self.name)
		object.can_detonate = false
		return

	if object.blocks_per_side % 2 != 0:
		print("ERROR: 'blocks_per_side' in '%s' must be an even number!" % self.name)
		object.can_detonate = false
		return
#
	# Set the debris timer.
	object.debris_timer.timeout.connect(_on_debris_timer_timeout)
	object.debris_timer.one_shot = true
	object.debris_timer.wait_time = object.debris_max_time
	object.debris_timer.name = "debris_timer"
	add_child(object.debris_timer, true)

	if debug_mode: print("--------------------------------")
	if debug_mode: print("Debug mode for '%s'" % self.name)
	if debug_mode: print("--------------------------------")

	# Use vframes and hframes to divide the sprite.
	# var sprite = get_node(object.sprite_name) as Sprite2D
	var sprite = get_node(object.sprite_name)
	# print('sprite ', sprite.name)
	# 保存原始的 frame 设置
	var original_frame = sprite.frame
	
	# 先获取原始尺寸
	var texture_size: Vector2
	if sprite.region_enabled:
		texture_size = sprite.region_rect.size * sprite.scale * 0.9 # FIXME
	else:
		texture_size = sprite.texture.get_size() * sprite.scale * 0.9

	if debug_mode:
		print('texture_size: ', texture_size)
	
	# get blocks v1
	# get_node(object.sprite_name).vframes = object.blocks_per_side
	# get_node(object.sprite_name).hframes = object.blocks_per_side
	# object.vframes = get_node(object.sprite_name).vframes
	# object.hframes = get_node(object.sprite_name).hframes
	# # 计算合适的分割数量，确保块的大小是整数
	var optimal_h_blocks = int(texture_size.x / 4) # 假设最小块宽度为16
	var optimal_v_blocks = int(texture_size.y / 4) # 假设最小块高度为16
	# print('optimal_h_blocks: ', optimal_h_blocks)
	# print('optimal_v_blocks: ', optimal_v_blocks)
	# # 确保分割数量是偶数
	optimal_h_blocks = optimal_h_blocks - (optimal_h_blocks % 2)
	optimal_v_blocks = optimal_v_blocks - (optimal_v_blocks % 2)
	
	# # 设置分割
	# sprite.frame = 0
	# sprite.vframes = optimal_v_blocks
	# sprite.hframes = optimal_h_blocks
	object.vframes = optimal_v_blocks
	object.hframes = optimal_h_blocks
	
	# # 计算每个块的大小
	# object.width = texture_size.x
	# object.height = texture_size.y
	
	# if debug_mode:
	# 	print("Sprite size: ", texture_size)
	# 	print("Blocks: ", Vector2(optimal_h_blocks, optimal_v_blocks))
	# 	print("Block size: ", Vector2(texture_size.x / optimal_h_blocks, texture_size.y / optimal_v_blocks))
	# 	print("Current frame: ", sprite.frame)

	if debug_mode: print("object's blocks per side: ", object.blocks_per_side)
	if debug_mode: print("object's total blocks: ", object.blocks_per_side * object.blocks_per_side)

	# Check if the sprite is using 'Region' to get the proper width and height.
	# 获取精灵节点
	var sprite_node = get_node(object.sprite_name)

	# 设置对象的宽度和高度
	if sprite_node.region_enabled:
		object.width = float(sprite_node.region_rect.size.x * sprite_node.scale.x)
		object.height = float(sprite_node.region_rect.size.y * sprite_node.scale.y)
	else:
		object.width = float(sprite_node.texture.get_width() * sprite_node.scale.x)
		object.height = float(sprite_node.texture.get_height() * sprite_node.scale.y)

	if debug_mode:
		print("object's width: ", object.width)
		print("object's height: ", object.height)

	# 计算偏移量
	if sprite_node.centered:
		object.offset = Vector2(object.width / 2, object.height / 2)
		if debug_mode:
			print("object is centered!")
			print("object's offset: ", object.offset)

	# var sprite_scale = sprite_node.scale

	# 计算碰撞区域
	object.collision_extents = Vector2((object.width / 2) / object.hframes,
									(object.height / 2) / object.vframes)

	if debug_mode:
		print('collision_extents: ', object.collision_extents)

	if debug_mode:
		print("object's collision_extents: ", object.collision_extents)

	object.collision_position = Vector2((ceil(object.collision_extents.x) - object.collision_extents.x) * -1,
										(ceil(object.collision_extents.y) - object.collision_extents.y) * -1)

	if debug_mode:
		print("object's collision_position: ", object.collision_position)

	# Defer the heavy block creation process
	call_deferred("initialize_blocks")


func initialize_blocks():
	# Move block creation logic here
	for n in range(object.vframes * object.hframes):
		var duplicated_object = self.duplicate(8)
		duplicated_object.name = self.name + "_block_" + str(n)
		duplicated_object._initialization_complete = true
		object.blocks.append(duplicated_object)
		
		# Setup block properties
		setup_block(duplicated_object, n)
	
	# Setup block positions
	setup_block_positions()
	
	# Add blocks to scene
	call_deferred("add_children", object)
	_initialization_complete = true

func setup_block(duplicated_object: Node, n: int):
	var shape = RectangleShape2D.new()
	shape.extents = object.collision_extents
	
	object.blocks[n].freeze = true
	object.blocks[n].get_node(object.sprite_name).vframes = object.vframes
	object.blocks[n].get_node(object.sprite_name).hframes = object.hframes
	object.blocks[n].get_node(object.sprite_name).frame = n
	object.blocks[n].get_node(object.collision_name).shape = shape
	object.blocks[n].get_node(object.collision_name).position = object.collision_position
	
	if object.collision_one_way:
		object.blocks[n].get_node(object.collision_name).one_way_collision = true

func setup_block_positions():
	var block_index = 0
	for x in range(object.vframes):
		for y in range(object.hframes):
			if block_index >= object.blocks.size():
				break
			var block = object.blocks[block_index]
			block.position = Vector2(
				y * (object.width / object.hframes) - object.offset.x + object.collision_extents.x + position.x,
				x * (object.height / object.vframes) - object.offset.y + object.collision_extents.y + position.y
			)
			block_index += 1

	if debug_mode:
		print("Current node: ", self.name)
		print("Parent node: ", get_parent().get_parent().name if get_parent() else "No parent")
		print("Scene tree valid: ", is_inside_tree())


	# 添加所有块作为子节点
	call_deferred("add_children", object)
	# add_children(object)
	_initialization_complete = true


	if debug_mode: print("--------------------------------")
	if debug_mode: debug_print_object()
	if debug_mode: print('object.parent: ', object.parent.name)

	contact_monitor = true
	max_contacts_reported = 4 # Set this according to your needs
	# body_entered.connect(_on_body_entered)
#
	# if explosion_detector:
	# 	print('detector collsion mask: ', explosion_detector.collision_mask)
	add_to_group("destructible")

	if node_to_explode is TileMap:
		print('load explode tilemap succeed')

func _physics_process(delta):
	# if object.parent:
	# 	print('object.parent: ', object.parent.name)
	# if object.can_detonate and object.detonate:
	# 	# Input.is_mouse_button_pressed(MouseButton.LEFT) and object.can_detonate:
	# 	# This is what triggers the explosion, setting 'object.detonate' to 'true'.
	# 	# print('explode')
	# 	# if debug_mode and not _debug_printed:
	# 	# 	debug_print_object()
	# 	# 	_debug_printed = true
	# 	object.detonate = true

	# print('global_position: ', global_position)

	if object.can_detonate and object.detonate:
		detonate()
		explosion(delta)

	if object.has_detonated:
		# Add a delay of 'delta' before counting the blocks.
		# Sometimes the last one doesn't get counted.
		if explosion_delay:
			# Removed the yield timer because it was throwing
			# 'Resumed after yield, but class instance is gone' errors
			# when freeing the blocks.
			# yield(get_tree().create_timer(delta), "timeout")
			explosion_delay_timer_limit = delta
			explosion_delay_timer += delta
			if explosion_delay_timer > explosion_delay_timer_limit:
				explosion_delay_timer -= explosion_delay_timer_limit
				# Remove the parent node after the last block is gone.
				if not object.blocks_container:
					object.blocks_container = get_node(self.name + "_blocks_container")
				
				if object.blocks_container and object.blocks_container.get_child_count() == 0:
					var current_parent = get_parent()
					if current_parent:
						current_parent.queue_free()
		else:
			# Remove the parent node after the last block is gone.
			if not object.blocks_container:
				object.blocks_container = get_node(self.name + "_blocks_container")
				
				if object.blocks_container and object.blocks_container.get_child_count() == 0:
					var current_parent = get_parent()
					if current_parent:
						current_parent.queue_free()

#
# func _integrate_forces(state):
# 	explosion(state.step)
#

func add_children(child_object):
	for i in range(child_object.blocks.size()):
		if debug_mode:
			print('add block of size: ', child_object.blocks[i].get_node(child_object.collision_name).shape.extents)
		var block = child_object.blocks[i]
		# 确保碎片不会干扰主体的碰撞检测
		block.contact_monitor = false
		block.set_collision_layer_value(1, true)
		child_object.blocks_container.add_child(child_object.blocks[i], true)
	# print('child_object: ', child_object)
	# print('parent: ', child_object.parent.name)
	if debug_mode:
		print('blocks_container: ', child_object.blocks_container)
	child_object.parent.add_child(child_object.blocks_container, true)

	# Move the self element faaaar away, instead of removing it,
	# so we can still use the script and its functions.
	self.position = Vector2(-999999, -999999)

# #
func detonate():

	# if not is_instance_valid(object.parent):
	# 	print("Warning: parent reference is invalid!")
	# 	return
	# print('detonating ', self.name)

	object.can_detonate = false
	object.has_detonated = true
	

	var current_parent = get_parent()
	if current_parent:
		# Check if the parent node has particles as a child.
		for child in current_parent.get_children():
			if child is GPUParticles2D or child is CPUParticles2D or child.is_in_group(fake_explosions_group):
				object.particles = child
				object.has_particles = true

	if object.has_particles:
		if object.particles is GPUParticles2D or object.particles is CPUParticles2D:
			object.particles.emitting = true
		elif object.particles.is_in_group(fake_explosions_group):
			object.particles.particles_explode = true

	for i in range(object.blocks_container.get_child_count()):

		# removed randomness
		var child = object.blocks_container.get_child(i)

		var child_gravity_scale = blocks_gravity_scale
		child.gravity_scale = child_gravity_scale

		var child_scale = randf_range(0.5, 1.5)
		# var child_scale = 1
		child.get_node(object.sprite_name).scale *= Vector2(child_scale, child_scale)
		child.get_node(object.collision_name).scale *= Vector2(child_scale, child_scale)

		# child.mass = child_scale

		# child.set_collision_layer(0 if randf() < 0.5 else object.collision_layers)
		# child.set_collision_layer_value(1, false)
		child.set_collision_layer_value(1, false)
		child.set_collision_mask(0 if randf() < 0.5 else object.collision_masks)

		child.z_index = 0 if randf() < 0.5 else -1
		# child.z_index = -1

		# var child_color = randf_range(100, 255) / 255
		# var tween = create_tween()
		# tween.tween_property(
		# 	child,
		# 	"modulate",
		# 	Color(child_color, child_color, child_color, 1.0),
		# 	0.25
		# )


		child.freeze = false
	object.debris_timer.start()

#
func explosion(delta):
	if object.detonate:
		if debug_mode: print("'%s' object exploded!" % self.name)

		for i in range(object.blocks_container.get_child_count()):
			var child = object.blocks_container.get_child(i)

			child.apply_central_impulse(Vector2(randf_range(-blocks_impulse, blocks_impulse), -blocks_impulse))

		# Add a delay before setting 'object.detonate' to 'false'.
		# Sometimes 'object.detonate' is set to 'false' so quickly that the explosion never happens.
		# If this happens, try setting 'explosion_delay' to 'true'.
		if explosion_delay:
			# Removed the yield timer because it was throwing
			# 'Resumed after yield, but class instance is gone' errors
			# when freeing the blocks.
			# yield(get_tree().create_timer(delta), "timeout")
			explosion_delay_timer_limit = delta
			explosion_delay_timer += delta
			if explosion_delay_timer > explosion_delay_timer_limit:
				explosion_delay_timer -= explosion_delay_timer_limit
				object.detonate = false
		else:
			object.detonate = false
#
#
func _on_debris_timer_timeout():
	if debug_mode: print("'%s' object's debris timer (%ss) timed out!" % [self.name, debris_max_time])
	
	for i in range(object.blocks_container.get_child_count()):
		var child = object.blocks_container.get_child(i)
		
		if not object.remove_debris:
			child.freeze = true
			child.get_node(object.collision_name).disabled = true
			
		# Remove the self element as we don't need it anymore.
			self.queue_free()
		else:
			var color_r = child.modulate.r
			var color_g = child.modulate.g
			var color_b = child.modulate.b
			var color_a = child.modulate.a
			
			var tween = create_tween()
			tween.tween_property(
				child,
				"modulate",
				Color(color_r, color_g, color_b, 0.0),
				randf_range(0.0, 1.0)
			)
			tween.tween_callback(child.queue_free)

#
#func _on_opacity_tween_completed(obj, _key):
	#obj.queue_free()

# func _on_body_entered(body: Node2D) -> void:
# 	# if debug_mode:
# 	# 	print("Collision detected with: ", body.name)
# 	# 	print("Collider type: ", body.get_class())
# 	# print('body enter name: ', body.name)
# 	# if body.get_parent():
# 	# 	print('body parent name: ', body.get_parent().name)
# 	# if body.owner:
# 	# 	print('body owner name: ', body.owner.name)
# 	print('self: detecting ', self.name)
# 	print('body: ', body.name)
# 	if body.get_parent():
# 		var parent = body.get_parent()
		
# 		# if parent:
# 		# 	print('parent name: ', parent.name)
# 		# 	print('parent has can_destroy: ', parent.get("can_destroy") != null)
# 		if parent.get("can_destroy") != null and parent.can_destroy and object.can_detonate:
# 			print('detonate', self.name)
# 			object.detonate = true
# 			global_position = Vector2(-999999, -999999)


func _on_trigger_entered(body: Node2D) -> void:

	# print('destruct_obj trigger', explosion_detector.collision_mask)
	# print("Area detected body: ", body.name)
		# print('body collision layer: ', body.tile_set.get_physics_layer_collision_layer()
	if body.get("can_destroy") != null and body.can_destroy and object.can_detonate:
		# print('destoryed', self.name)
		# print("Triggering explosion from area detection by", body.name)
		object.detonate = true
	elif body.get_parent():
		var parent = body.get_parent()
		if parent.get("can_destroy") != null and parent.can_destroy and object.can_detonate:
			# print('destoryed', self.name)
			# print("Triggering explosion from area detection by", body.name)
			object.detonate = true
		else:
			# print('not trigger destroy by ', body.name)
			pass


func debug_print_object() -> void:
	print("\n=== Debug Object Info ===")
	print("Basic Info:")
	print("- Can detonate:", object.can_detonate)
	print("- Has detonated:", object.has_detonated)
	print("- Has particles:", object.has_particles)
	
	print("\nDimensions:")
	print("- Width:", object.width)
	print("- Height:", object.height)
	print("- Offset:", object.offset)
	
	print("\nBlocks Info:")
	print("- Blocks per side:", object.blocks_per_side)
	print("- Total blocks:", object.blocks.size())
	print("- VFrames:", object.vframes)
	print("- HFrames:", object.hframes)
	
	print("\nCollision Settings:")
	print("- Collision layers:", object.collision_layers)
	print("- Collision masks:", object.collision_masks)
	print("- Collision one way:", object.collision_one_way)
	print("- Collision extents:", object.collision_extents)
	print("- Collision position:", object.collision_position)
	
	print("\nNode References:")
	print("- Parent node:", object.parent.name if object.parent else "None")
	print("- Sprite name:", object.sprite_name)
	print("- Collision name:", object.collision_name)
	print("- Blocks container name:", object.blocks_container.name)
	print("- Blocks container child count:", object.blocks_container.get_child_count())
	
	print("\nPhysics Settings:")
	print("- Blocks gravity scale:", object.blocks_gravity_scale)
	print("- Blocks impulse:", object.blocks_impulse)
	
	print("\nDebris Settings:")
	print("- Debris max time:", object.debris_max_time)
	print("- Remove debris:", object.remove_debris)
	print("======================\n")
