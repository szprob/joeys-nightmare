extends Control

var meta_path = "res://scenes/day/inventory/inventory_meta.json"
var inventory_state = []
var inventory_dict = {}

@onready var item_list: ItemList = %ItemList
@onready var detial_panel: Panel = %ItemPanel
@onready var item_title: Label = %ItemTitle
@onready var item_detail: RichTextLabel = %ItemDetail

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_item_detail_panel()
	load_inventory_info()
	set_item_position()
	hide()

func _notification(what: int) -> void:
	if what != NOTIFICATION_VISIBILITY_CHANGED:
		return

	if not is_node_ready():
		return

	if not visible:
		return

	hide_item_detail_panel()
	item_list.clear()
	for item_name in GameManager.get_items():
		var index = item_list.add_item(item_name)
		item_list.set_item_icon(index, load("res://icon.svg"))


func _process(delta: float) -> void:
	if is_instance_valid(get_tree().current_scene) and not get_tree().current_scene.tree_entered.is_connected(hide):
		get_tree().current_scene.tree_entered.connect(hide)

	if not visible and Input.is_action_just_pressed("inventory") and not GameManager.is_chatting():
		show()
		print("show inventory")
		return

	if visible and (Input.is_action_just_pressed("inventory")):
		hide()
		hide_item_detail_panel()
		print("hide inventory")
		return


func load_inventory_info() -> void:
	var file = FileAccess.open(meta_path, FileAccess.READ)
	if file:
		var save_text = file.get_as_text()
		var json = JSON.new()
		var result = json.parse(save_text)
		if result == OK:
			inventory_state = json.data
			print(inventory_state[0])
		else:
			print("JSON Parse Error at line ",json.get_error_line())
		file.close()

func show_item_panel(item) -> void:
	detial_panel.show()
	item_title.text = item["description"]

func set_item_position() -> void:
	var added_items = []
	for item in inventory_state:
		inventory_dict[item['name']] = item
		print(item)
		if item['index'] != -1:
			added_items.append(item)
	added_items.sort_custom(func(l, r): l['index'] < r['index'])
		

# 隐藏物品详情面板
func hide_item_detail_panel():
	detial_panel.hide()
	item_title.text = ""

func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	detial_panel.show()
	var item_name = item_list.get_item_text(index)
	item_title.text = item_name
	if not inventory_dict.has(item_name):
		printerr("\"%s\"未定义，请在 inventory_meta.json 中进行定义。" % item_name)
	item_detail.text = inventory_dict.get(item_name, {}).get('description', "\"%s\"未定义，请在背包索引文件中进行定义。撒的阿斯顿撒的阿斯顿撒的阿斯顿爱上阿斯顿爱上打算爱上爱上打算阿斯顿撒打算撒的爱上爱上撒的" % item_name)
