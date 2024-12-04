extends Node2D

@onready var door1: AnimatedSprite2D = $Door1
@onready var door2: AnimatedSprite2D = $Door2
@onready var door3: AnimatedSprite2D = $Door3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	door1.play("open")
	door2.frame = 5
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
