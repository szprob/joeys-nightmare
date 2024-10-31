extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open():
	print('open door')
	self.set_collision_layer(0)
	self.visible=false
	
func close():
	print('close door')
	self.set_collision_layer(1)
	self.visible=true
