extends Node

var score = 0 

@onready var score_label: Label = $score_label


func add_point():
	score += 1 
	score_label.text = 'current score : '+ str(score)
