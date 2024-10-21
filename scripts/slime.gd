extends CharacterBody2D

var direction = 1 

@onready var ray_cast_2d_right: RayCast2D = $RayCast2D_right
@onready var ray_cast_2d_left: RayCast2D = $RayCast2D_left
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ray_cast_2d_left.is_colliding():
		direction = 1 
		animated_sprite_2d.flip_h = false 
	if ray_cast_2d_right.is_colliding():
		direction = -1 
		animated_sprite_2d.flip_h = true  
	position.x += direction * Globals.SLIME_SPPED * delta 
	# Add the gravity.
	if not is_on_floor():
		#print(collision_shape_2d.collision_mask)
		velocity += get_gravity() * delta
	move_and_slide()
