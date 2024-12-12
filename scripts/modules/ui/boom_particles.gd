# 粒子场景的脚本
extends GPUParticles2D

func _ready():
    emitting = false
    one_shot = true
    explosiveness = 1.0
    lifetime = 1.0
    
    # 使用自定义的粒子贴图（可以是方块或不规则的碎片形状）
    var texture = preload("res://path_to_your_particle_texture.png")
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    texture = texture