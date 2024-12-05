extends Area2D

var gravity_strength := 980.0
var player_in_area := false

func _ready() -> void:
	# Connect the body_entered and body_exited signals
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _process(delta: float) -> void:
	if player_in_area:
		# Get the player node
		var player = get_node("path/to/player") # Update with the correct path to the player node
		if player:
			# Calculate the direction from the area to the player
			var direction = (player.global_position - global_position).normalized()
			# Set the gravity direction based on the player's position
			set_gravity_direction(direction)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_area = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_area = false

func set_gravity_direction(direction: Vector2) -> void:
	# Apply the new gravity direction to the physics engine or player
	# This is a placeholder function, implement the actual logic here
	pass
