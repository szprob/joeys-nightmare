extends CharacterBody2D

@export var pause_points: Array[float] = [] # 在路径上的暂停点（0-1之间的值）
@export var pause_duration: float = 1.0
@export var speed = 40
@onready var path_follow: PathFollow2D = get_parent()

var is_paused: bool = false
var pause_timer: float = 0.0
var moving_forward: bool = true

func _ready() -> void:
	path_follow.progress = 0.0

func _physics_process(delta: float) -> void:
	var path_length = path_follow.get_parent().curve.get_baked_length()
	var movement = speed * delta
	
	path_follow.progress += movement
