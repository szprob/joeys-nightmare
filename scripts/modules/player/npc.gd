extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialogue_area: Area2D = $DialogueArea
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

enum NPCState {
    IDLE,
    WALKING,
    TALKING
}

var current_state: NPCState = NPCState.IDLE
var movement_speed: float = 100.0
var dialogue_data: Dictionary = {}
var can_interact: bool = true
var player_in_range: bool = false

func _ready() -> void:
    # 初始化对话区域信号
    dialogue_area.body_entered.connect(_on_dialogue_area_body_entered)
    dialogue_area.body_exited.connect(_on_dialogue_area_body_exited)
    _update_animation()

func _physics_process(delta: float) -> void:
    match current_state:
        NPCState.IDLE:
            _process_idle_state()
        NPCState.WALKING:
            _process_walking_state(delta)
        NPCState.TALKING:
            _process_talking_state()

func _process_idle_state() -> void:
    _update_animation()

func _process_walking_state(delta: float) -> void:
    if navigation_agent.is_navigation_finished():
        current_state = NPCState.IDLE
        return
        
    var next_position = navigation_agent.get_next_path_position()
    var direction = global_position.direction_to(next_position)
    velocity = direction * movement_speed
    move_and_slide()
    _update_animation()

func _process_talking_state() -> void:
    _update_animation()

func _update_animation() -> void:
    match current_state:
        NPCState.IDLE:
            animated_sprite.play("idle")
        NPCState.WALKING:
            animated_sprite.play("walk")
            # 根据移动方向翻转精灵
            animated_sprite.flip_h = velocity.x < 0
        NPCState.TALKING:
            animated_sprite.play("talk")

func set_movement_target(target_position: Vector2) -> void:
    navigation_agent.set_target_position(target_position)
    current_state = NPCState.WALKING

func start_dialogue() -> void:
    if can_interact and player_in_range:
        current_state = NPCState.TALKING
        # 在这里触发对话系统
        # DialogueManager.start_dialogue(dialogue_data)

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
