extends AnimatableBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var rotation_angular_velocity: float = 5.0
@export var pivot_position: Area2D
@export var flame_number: int = 3
@export var clockwise: bool = true

var flames: Array[AnimatedSprite2D] = []
var radius: float = 50.0  # 火焰到pivot的距离
var current_angle: float = 0.0

func _ready():
    # 创建多个火焰
    for i in range(flame_number):
        var new_flame = animated_sprite.duplicate()
        add_child(new_flame)
        flames.append(new_flame)
        
        # 计算每个火焰的初始位置
        var angle = (2 * PI / flame_number) * i
        var pos = Vector2(radius * cos(angle), radius * sin(angle))
        new_flame.position = pivot_position.position + pos

func _physics_process(delta):
    # 更新旋转角度
    var rotation_direction = -1 if clockwise else 1
    current_angle += rotation_angular_velocity * delta * rotation_direction
    
    # 更新所有火焰的位置
    for i in range(flame_number):
        var angle = current_angle + (2 * PI / flame_number) * i
        var pos = Vector2(radius * cos(angle), radius * sin(angle))
        flames[i].position = pivot_position.position + pos


