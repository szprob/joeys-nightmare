extends Area2D

@export var light_tile: TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func action() -> void:
	if light_tile.visible:
		light_tile.hide()
	else:
		light_tile.show()
