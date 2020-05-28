extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var btn_pre = "HBoxContainer/VBoxContainer/";


# Called when the node enters the scene tree for the first time.
func _ready():
	var continue_btn = get_node(btn_pre + "Continue")
	continue_btn.grab_focus()
	print("test: " + Global.language)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Continue_pressed():
	get_tree().change_scene("res://code/tscn/Stage.tscn")

func _on_New_Game_pressed():
	get_tree().change_scene("res://code/tscn/Stage_prueba.tscn")

func _on_Options_pressed():
	get_tree().change_scene("res://code/tscn/Options.tscn")

func _on_Exit_pressed():
	get_tree().quit()
	
