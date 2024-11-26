extends Area2D

@export var rotation_speed: float = 0.2  # 旋转速度,可在编辑器中调整
@export var radius: float = 100.0        # 摩天轮半径

func _ready() -> void:
    # 初始化时可以添加必要的设置
    pass

func _process(delta: float) -> void:
    # 每帧更新旋转角度
    rotation += rotation_speed * delta