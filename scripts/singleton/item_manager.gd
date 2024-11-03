class_name ItemMnager
extends Node

var parent: GameManager

var inventory = []

func _init(parent_node: Node):
	parent = parent_node

func add_item(item_name:StringName)->void:
	inventory.append(item_name)

func use_item(item_name:StringName) -> void:
	inventory.erase(item_name)

func has_item(item_name:StringName) -> bool:
	return inventory.has(item_name)

func get_items() -> Array[StringName]:
	return Array(inventory, TYPE_STRING_NAME, &"", null)
