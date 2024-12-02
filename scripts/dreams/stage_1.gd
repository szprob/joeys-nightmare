extends Node2D


func _ready():
	print("夜晚物品栏： ", GameManager['game_state']['inventory'])
	print("是否包含物品[" , "玩具手枪", "]: ", GameManager.has_item("玩具手枪"))
	print("是否包含物品[" , &"玩具手枪", "]: ", GameManager.has_item(&"玩具手枪"))
	print("get_items: ", GameManager.get_items())
