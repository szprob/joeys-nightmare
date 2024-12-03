extends AnimatableBody2D

@export var rotation_angular_velocity: float = 5.0
@export var flame_number: int = 3
@export var clockwise: bool = true

var flame_scene = preload("res://scenes/modules/traps/fire.tscn")
var flames = []
var radius = 50  # 火焰旋转的半径
var center_pos: Vector2
var current_angle = 0.0

func _ready():
    center_pos = global_position
    spawn_flames()

func spawn_flames():
    var angle_step = 2 * PI / flame_number
    
    for i in range(flame_number):
        var flame = flame_scene.instantiate()
        var angle = angle_step * i
        var pos = Vector2(
            center_pos.x + cos(angle) * radius,
            center_pos.y + sin(angle) * radius
        )
        flame.global_position = pos
        get_parent().add_child(flame)
        flames.append(flame)

func _process(delta):
    var rotation_direction = -1 if clockwise else 1
    current_angle += rotation_angular_velocity * delta * rotation_direction
    
    for i in range(flame_number):
        var angle = current_angle + (2 * PI / flame_number) * i
        var new_pos = Vector2(
            center_pos.x + cos(angle) * radius,
            center_pos.y + sin(angle) * radius
        )
        flames[i].global_position = new_pos



