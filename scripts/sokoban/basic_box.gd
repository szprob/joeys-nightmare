extends CharacterBody2D


# var gravity = 98
var push_strength = 100 # 推动的力度
var mass = 1

func _ready():
	add_to_group("pushable")
	pass

func _physics_process(delta):
	velocity += get_gravity() * delta / mass
	move_and_slide()
	
func push(direction: Vector2):
	print('try push')
	velocity = direction * push_strength
	move_and_slide()
	velocity = Vector2.ZERO
	print('Box is being pushed in direction:', direction)
