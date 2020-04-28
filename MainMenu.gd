extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var MouseOver = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			get_tree().change_scene("res://Stage.tscn")

	if Input.is_key_pressed(KEY_SPACE):
		#code
		get_tree().change_scene("res://Stage.tscn")

