extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Camera area _ready called")
	body_entered.connect(_on_body_entered)
	
	# Check if player is already inside the area
	var overlapping_bodies = get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("player"):
			_on_body_entered(body)
			print("Found player already in area")

# Handle when player enters the area
func _on_body_entered(body: Node2D) -> void:
	print("Body entered: ", body.name)
	if body.is_in_group("player"):
		var collision_shape = $CollisionShape2D
		var camera = body.get_node("Camera2D")
		
		# Get rectangle shape and consider scale
		var rect_shape = collision_shape.shape as RectangleShape2D
		var scale = collision_shape.scale
		
		# Calculate actual size considering scale
		var actual_size = rect_shape.size * scale
		var global_pos = collision_shape.global_position
		
		print("Original shape size: ", rect_shape.size)
		print("Shape scale: ", scale)
		print("Actual size: ", actual_size)
		print("Global position: ", global_pos)
		
		# Set camera limits using scaled size
		camera.limit_left = global_pos.x - actual_size.x/2
		camera.limit_right = global_pos.x + actual_size.x/2
		camera.limit_top = global_pos.y - actual_size.y/2
		camera.limit_bottom = global_pos.y + actual_size.y/2
		
		print("Camera limits:")
		print("Left: ", camera.limit_left)
		print("Right: ", camera.limit_right)
		print("Top: ", camera.limit_top)
		print("Bottom: ", camera.limit_bottom)
		
