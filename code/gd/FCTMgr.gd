extends Node2D

var FCT = preload("res://code/tscn/FCT.tscn")

export var travel = Vector2(0, -80)
export var duration = 2
export var spread = PI/2

func show_value(value, crit=false):
	var fct = FCT.instance()
	add_child(fct)
	fct.show_value(str(value), travel, duration, spread, crit)

func show_speech_bubble(value, duration):
	var fct = FCT.instance()
	add_child(fct)
	fct.show_speech_bubble(value,  Vector2(0, 0), duration, spread)
