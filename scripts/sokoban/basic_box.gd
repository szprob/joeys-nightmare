extends CharacterBody2D


var gravity = 98
var push_strength = 200  # 推动的力度


func _ready():
	pass

func _physics_process(delta):
	velocity += get_gravity() * delta
	move_and_slide()
	
func push(direction: Vector2):
	print('try push')
	velocity = direction * push_strength
	move_and_slide()
	print('Box is being pushed in direction:', direction)
