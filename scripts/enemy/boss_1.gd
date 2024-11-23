extends CharacterBody2D

@onready var player = get_tree().get_first_node_in_group("player")
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 2.0  # 发射间隔时间
@export var bullet_speed: float = 200.0  # 子弹速度

var can_shoot: bool = true

func _ready():
    # 创建一个计时器用于控制射击间隔
    var timer = Timer.new()
    timer.wait_time = shoot_interval
    timer.timeout.connect(_on_shoot_timer_timeout)
    add_child(timer)
    timer.start()

func _physics_process(_delta):
    if player:
        # 获取朝向玩家的方向
        var direction = (player.global_position - global_position).normalized()
        # 可以添加boss的旋转,使其面向玩家
        rotation = direction.angle()
        
        if can_shoot:
            shoot(direction)

func shoot(direction: Vector2):
    # 创建子弹实例
    var bullet = bullet_scene.instantiate()
    # 设置子弹位置和速度
    bullet.global_position = global_position
    bullet.velocity = direction * bullet_speed
    # 将子弹添加到场景中
    get_tree().current_scene.add_child(bullet)
    can_shoot = false

func _on_shoot_timer_timeout():
    can_shoot = true


