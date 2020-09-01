extends KinematicBody2D

class_name Enemy

const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)

const STATE_WALKING = 0
const STATE_ATTACKING = 1
const STATE_ALERTED = 2
const STATE_KILLED = 3

const WALK_SPEED = 70 
const MAX_ALERT_TIME = 20

var HEALTH = 20
var alert_timer = 0
var in_attack_range = false
var in_detection_range = false

var linear_velocity = Vector2()
var direction = -1
var anim = ""
var player_target_ref = null
var can_walk = true

# state machine
var state = STATE_WALKING

onready var DetectFloorLeft = $DetectFloorLeft
onready var DetectWallLeft = $DetectWallLeft
onready var DetectFloorRight = $DetectFloorRight
onready var DetectWallRight = $DetectWallRight
onready var CollisionShape2D = $CollisionShape2D
onready var sprite = $Sprite
onready var AlertRange = $Sprite/AlertRange

func _physics_process(delta):
	var new_anim = "idle"

	if state != STATE_KILLED:
		if state == STATE_WALKING || state == STATE_ALERTED:
			linear_velocity += GRAVITY_VEC * delta

			if can_walk:
				linear_velocity.x = direction * WALK_SPEED
			else:
				linear_velocity.x = 0

			linear_velocity = move_and_slide(linear_velocity, FLOOR_NORMAL)

			can_walk = true

			if not DetectFloorLeft.is_colliding():
				if state == STATE_WALKING:
					direction = 1.0
				else:
					can_walk = false

			if DetectWallLeft.is_colliding():
				if state == STATE_WALKING:
					direction = 1.0
				else:
					can_walk = false

			if not DetectFloorRight.is_colliding():
				if state == STATE_WALKING:
					direction = -1.0
				else:
					can_walk = false

			if DetectWallRight.is_colliding():
				if state == STATE_WALKING:
					direction = -1.0
				else:
					can_walk = false

			sprite.scale = Vector2(direction, 1.0)
			if can_walk:
				new_anim = "walk"
			else:
				new_anim = "walk"

			if state == STATE_ALERTED:
				if player_target_ref.position.x > position.x:
					direction = 1.0
				else:
					direction = -1.0

				if alert_timer > MAX_ALERT_TIME:
					state = STATE_WALKING
					alert_timer = 0
					$FCTMgr.show_speech_bubble("¡ON FUE!", 5)		
				else:
					alert_timer += delta

		elif state == STATE_ATTACKING:
			new_anim = "Attack"

	else:
		new_anim = "explode"

	if anim != new_anim:
		anim = new_anim
		($Anim as AnimationPlayer).play(anim)

func attack_end():
	if in_attack_range:
		anim = "idle"
	else:
		state = STATE_ALERTED

func hit_by_bullet():
	if state != STATE_KILLED:
		var dmg = randi() % 10 + 1
		var crit = true if randi() % 100 < 10 else false
		$FCTMgr.show_value(dmg, crit)

		HEALTH -= dmg

		if HEALTH <= 0:
			state = STATE_KILLED
			CollisionShape2D.set_deferred("disabled", true)

func _on_KnifeHit_body_entered(body):
	if state != STATE_KILLED:
		if body.has_method("hit_by_enemy"):
			body.hit_by_enemy()

func _on_AttackRange_body_entered(body):
	if state != STATE_KILLED:
		state = STATE_ATTACKING
		in_attack_range = true
		player_target_ref = body

func _on_AttackRange_body_exited(body):
	in_attack_range = false

func _on_DetectionRange_body_entered(body):
	if state != STATE_KILLED:
		in_detection_range = true
		alert_timer = 0
		player_target_ref = body
		state = STATE_ALERTED
		$FCTMgr.show_speech_bubble("¡ATRAPENLO!", 5)		
		for ally in AlertRange.get_overlapping_bodies():
			if ally != self:
				if ally.has_method("panic"):
					ally.panic(body)


func _on_DetectionRange_body_exited(body):
	in_detection_range = false

func panic(body):
	if state != STATE_KILLED:
		$FCTMgr.show_speech_bubble("!", 5)
		state = STATE_ALERTED
		player_target_ref = body
		alert_timer = 0

