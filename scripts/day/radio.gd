extends Sprite2D

var full_text = "Joey，听得见吗???"
var delay: float = 0.05
var talking: bool = false
var joey_triggered: bool = false

@onready var actionable: Area2D = $Actionable
@onready var dialogue: Label = $RadioDialogue

const BubbleScene = preload("res://scenes/day/room1/day_bubble.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	actionable.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.get_day_phase() == 2 and not talking:
		create_bubble()

func create_bubble() -> void:
	# 首先获取当前文本并处理前缀
	talking = true
	SoundPlayer.play_sound("res://assets/sounds/day/old-radio-noise-46734.mp3")
	var current_text = full_text
	print("position", global_position)
	var bubble_position = global_position + Vector2(-50, -20)
	# 然后创建气泡实例并使用处理后的文本
	var bubble_instance = BubbleScene.instantiate()
	bubble_instance.text = current_text
	bubble_instance.font_size = 6
	bubble_instance.t = 2
	bubble_instance.text_speed = 0.1
	bubble_instance.global_position = bubble_position
	get_parent().add_child(bubble_instance)
