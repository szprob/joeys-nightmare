extends Control

@onready var pack_intro: Label = $PackIntro
@onready var check_intro: Label = $CheckIntro
@export var track_camera: Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_intro.hide() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	# position = Vector2(-track_camera.limit_right, -track_camera.limit_bottom + 3)


func show_check() -> void:
	check_intro.show()

func hide_check() -> void:
	check_intro.hide()
