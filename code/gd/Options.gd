extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var btn_pre = "HBoxContainer/VBoxContainer/";

# Called when the node enters the scene tree for the first time.
func _ready():
	var back_btn = get_node(btn_pre + "Back")
	back_btn.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Back_pressed():
	get_tree().change_scene("res://code/tscn/MainMenu.tscn")

