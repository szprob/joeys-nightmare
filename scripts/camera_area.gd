extends Area2D

var is_active := false  # Track if this area is currently affecting the camera
var last_entered_area: Area2D = null  # Track the last entered camera area

# Add reference to limit shape
@onready var limit_shape: CollisionShape2D = $LimitShape2D

func _ready() -> void:
	print("Camera area _ready called")
	if !body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if !body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
	
	# Check if player is already in area
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			_on_body_entered(body)

# Calculate camera limits based on all active areas
func calculate_camera_limits() -> Dictionary:
	var limits = {
		"left": -10000000,
		"right": 10000000,
		"top": -10000000,
		"bottom": 10000000
	}
	
	if is_active:
		# Use limit_shape instead of trigger shape
		var rect = limit_shape.shape as RectangleShape2D
		var size = rect.size * limit_shape.scale
		var pos = limit_shape.global_position
		
		limits.left = pos.x - size.x / 2
		limits.right = pos.x + size.x / 2
		limits.top = pos.y - size.y / 2
		limits.bottom = pos.y + size.y / 2
	
	return limits
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Body entered:", body.name)
		last_entered_area = self
		
		# Immediately activate this area and deactivate others
		for area in get_tree().get_nodes_in_group("camera_area"):
			area.is_active = (area == self)
		
		var camera = body.get_node("Camera2D")
		var limits = calculate_camera_limits()
		
		camera.limit_left = limits.left
		print('camera.limit_left',camera.limit_left)
		
		camera.limit_right = limits.right
		camera.limit_top = limits.top
		camera.limit_bottom = limits.bottom

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Body exited:", body.name)
		if !get_overlapping_bodies().has(body):
			is_active = false
			
			# Find the area that currently contains the player
			var current_area: Area2D = null
			for area in get_tree().get_nodes_in_group("camera_area"):
				if area != self and area.get_overlapping_bodies().has(body):
					current_area = area
					break
			
			# If found, trigger its enter event
			if current_area:
				current_area._on_body_entered(body)
