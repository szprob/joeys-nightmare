extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialogue_area: Area2D = $DialogueArea
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

enum NPCState {
    IDLE,
    WALKING,
}

var current_state: NPCState = NPCState.IDLE
var movement_speed: float = 100.0
var dialogue_data: Dictionary = {}
var can_interact: bool = true
var player_in_range: bool = false
var is_dialogue_active: bool = false

# 添加新的导入
const DialogueResourceFile = preload("res://addons/dialogue_manager/dialogue_resource.gd")
const DialogueManagerFile = preload("res://addons/dialogue_manager/dialogue_manager.gd")
const PortalScene = preload("res://scenes/modules/checkpoints/empty-teleport.tscn")

# 添加新的变量
@export var dialogue_resource: DialogueResourceFile
@export var dialogue_start: String = "start"
@export var dialogue_default: String = "default"




func _ready() -> void:
    # 初始化对话区域信号
    dialogue_area.body_entered.connect(_on_dialogue_area_body_entered)
    dialogue_area.body_exited.connect(_on_dialogue_area_body_exited)
    _update_animation()

func _physics_process(delta: float) -> void:
    if not visible:
        queue_free()

    if player_in_range:
        if Input.is_action_just_pressed("select"):
            start_dialogue()

    match current_state:
        NPCState.IDLE:
            _process_idle_state()
        NPCState.WALKING:
            _process_walking_state(delta)

func _process_idle_state() -> void:
    _update_animation()

func _process_walking_state(_delta: float) -> void:
    if navigation_agent.is_navigation_finished():
        current_state = NPCState.IDLE
        return
        
    var next_position = navigation_agent.get_next_path_position()
    var direction = global_position.direction_to(next_position)
    velocity = direction * movement_speed
    move_and_slide()
    _update_animation()

func _update_animation() -> void:
    match current_state:
        NPCState.IDLE:
            animated_sprite.play("idle")
        NPCState.WALKING:
            animated_sprite.play("move")
            # 根据移动方向翻转精灵
            animated_sprite.flip_h = velocity.x < 0

func set_movement_target(target_position: Vector2) -> void:
    navigation_agent.set_target_position(target_position)
    current_state = NPCState.WALKING

func start_dialogue() -> void:
    if can_interact and player_in_range and not is_dialogue_active:
        current_state = NPCState.TALKING
        is_dialogue_active = true
        
        # 使用 get_singleton() 获取 DialogueManager 实例
        var dialogue_manager = get_node("/root/DialogueManager")
        dialogue_manager.show_dialogue_balloon(
            dialogue_resource,
            dialogue_start,
            {
                "npc": self,
            }
        )
        
        # 监听对话结束事件
        dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_ended(_resource: DialogueResourceFile) -> void:
    current_state = NPCState.IDLE
    is_dialogue_active = false
    # 使用实例断开信号连接
    get_node("/root/DialogueManager").dialogue_ended.disconnect(_on_dialogue_ended)

func _on_dialogue_area_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_in_range = true

func _on_dialogue_area_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_in_range = false

func set_dialogue_data(data: Dictionary) -> void:
    dialogue_data = data

func set_interactable(value: bool) -> void:
    can_interact = value

# 添加新的函数
func create_portal_and_disappear(portal_position: Vector2) -> void:
    # 创建传送门实例
    var portal = PortalScene.instantiate()
    get_parent().add_child(portal)
    portal.global_position = portal_position
    
    # NPC走向传送门
    set_movement_target(portal_position)
    

