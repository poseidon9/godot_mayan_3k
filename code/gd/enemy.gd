extends KinematicBody2D

class_name Enemy

const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)

const STATE_WALKING = 0
const STATE_KILLED = 1
const WALK_SPEED = 70 

var HEALTH = 100

var linear_velocity = Vector2()
var direction = -1
var anim = ""

# state machine
var state = STATE_WALKING

onready var DetectFloorLeft = $DetectFloorLeft
onready var DetectWallLeft = $DetectWallLeft
onready var DetectFloorRight = $DetectFloorRight
onready var DetectWallRight = $DetectWallRight
onready var CollisionShape2D = $CollisionShape2D
onready var sprite = $Sprite

func _physics_process(delta):
	var new_anim = "idle"

	if state == STATE_WALKING:
		linear_velocity += GRAVITY_VEC * delta
		linear_velocity.x = direction * WALK_SPEED
		linear_velocity = move_and_slide(linear_velocity, FLOOR_NORMAL)
		
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.collider.name == "Player":
				collision.collider.call("hit_by_enemy")

		if not DetectFloorLeft.is_colliding():
			direction = 1.0

		if DetectWallLeft.is_colliding():
			var object = DetectWallLeft.get_collider()
			if object.get_name() != "Player" and object.get_name() != "Bullet":
				direction = 1.0

		if not DetectFloorRight.is_colliding():
				direction = -1.0

		if DetectWallRight.is_colliding():
			var object = DetectWallRight.get_collider()
			if object.get_name() != "Player" and object.get_name() != "Bullet":
				direction = -1.0

		sprite.scale = Vector2(direction, 1.0)
		new_anim = "walk"
	else:
		new_anim = "explode"

	if anim != new_anim:
		anim = new_anim
		($Anim as AnimationPlayer).play(anim)

func hit_by_bullet():
	if state != STATE_KILLED:
		var dmg = randi() % 10 + 1
		var crit = true if randi() % 100 < 10 else false
		$FCTMgr.show_value(dmg, crit)

		HEALTH -= dmg

		if HEALTH <= 0:
			state = STATE_KILLED
			CollisionShape2D.set_deferred("disabled", true)
