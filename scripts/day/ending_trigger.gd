extends Area2D

@onready var room_light: DirectionalLight2D = %RoomLight
@onready var no_way: StaticBody2D = %NoWay
@onready var landscape: TextureRect = %Landscape
var music_played: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	room_light.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if is_instance_of(body, CharacterBody2D):
		if not music_played:
			var mirror1 = get_tree().current_scene.get_node("/root/Game/Room1/Mirror") as Node2D
			var mirror2 = get_tree().current_scene.get_node("/root/Game/Room2/Mirror") as Node2D
			mirror1.hide()
			mirror2.hide()
			landscape.show()
			room_light.show()
			no_way.collision_layer = 1
			SoundPlayer.play_sound("res://assets/sounds/day/soft-piano-100-bpm-121529.mp3", true)
			music_played = true
