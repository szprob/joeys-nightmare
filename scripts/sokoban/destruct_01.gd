extends Node2D

@onready var detector: Area2D = $detector

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the body entered signal from detector
	detector.body_entered.connect(_on_detector_body_entered)

# Handle collision detection
func _on_detector_body_entered(body: Node2D) -> void:
	print('body entered: ', body)
	# Call detonate function on the destruct-obj child node
	$"destruct-obj".detonate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
