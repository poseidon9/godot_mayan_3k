extends Node2D

class_name OmarTempWall

onready var sprite = $Sprite

func _on_Area2D_body_entered(body):
	sprite.hide()

func _on_Area2D_body_exited(body):
	sprite.show()
