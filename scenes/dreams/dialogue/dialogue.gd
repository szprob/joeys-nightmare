extends Node

var dialogue_data: Dictionary = {
	"stage1_begin": [
		"npc:又见面了,joey",
		"npc:这是你试图离开这里的第31次",
		"npc:衷心希望你能走出这段梦魇",
		"npc:坚持下去吧,我们会再见面的"
	],
	"stage1_end": [
		"npc:做的不错,joey",
		"npc:恭喜你通过了第一道考验",
		"npc:明晚我们再见",
		"npc:记得检查一下衣柜",
		"npc:小时候的你很喜欢藏东西在哪儿"
	],
	'befor_die': [
		"npc:快跑!!!!"
	],
	'die': [
		"npc:活下去....."
	],
	'cave': [
		"npc:来这边！"
	],
}

# _ready 函数可以移除，因为我们直接在变量声明时初始化对话数据
func _ready():
	pass
