extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
onready var anim_player : AnimationPlayer = find_node("AnimationPlayer")

func _ready():
	assert (anim_player != null)
	animation_handler()

func animation_handler():
	anim_player.play("idle")
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
