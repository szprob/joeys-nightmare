extends Camera2D

var shake_magnitude = 4.0  # 振动幅度
var shake_duration = 0.5  # 振动持续时间
var shake_timer = 0.0
var target: Node2D = null  # 添加目标节点变量

func _ready():
    # 获取玩家节点
    target = get_tree().get_first_node_in_group("player")
    if not target:
        push_warning("Camera2D: 未找到player组的节点")

func _process(delta):
    var target_pos = Vector2.ZERO  # 在这里声明并初始化
    if target:
        target_pos = target.global_position
        
    if shake_timer > 0:
        shake_timer -= delta
        var shake_offset = Vector2(randf_range(-shake_magnitude, shake_magnitude), randf_range(-shake_magnitude, shake_magnitude))
        shake_offset *= (shake_timer / shake_duration)
        global_position = target_pos + shake_offset  # 修改：基于目标位置添加偏移
    else:
        global_position = target_pos if target else Vector2.ZERO  # 修改：如果有目标就跟随目标

func shake(duration, magnitude):
    shake_duration = duration
    shake_magnitude = magnitude
    shake_timer = duration