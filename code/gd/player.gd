extends KinematicBody2D

class_name Player


const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const WALK_SPEED = 250 # pixels/sec
const RUN_SPEED = 600 # pixels/sec
const JUMP_SPEED = 320
const SIDING_CHANGE_SPEED = 10
const BULLET_VELOCITY = 800
const SHOOT_TIME_SHOW_WEAPON = 0.1
const MAX_MULTI_JUMP = 2
const COMBINATION_TIMING_TRESHOLD = 0.3
const MAX_DASHING_TIME = 0.25

var DASHING = false
var CAN_DASH = true
var MULTI_JUMP = 2
var ACTIONS = []
var DASHING_TIME = 0
var FACING = 1; #-1 left, 1 right

var linear_vel = Vector2()
var shoot_time = 99999 # time since last shot
var last_action_time = 99999

var anim = ""

# cache the sprite here for fast access (we will set scale to flip it often)
onready var sprite = $Sprite
# cache bullet for fast access
var Bullet = preload("res://code/tscn/Bullet.tscn")

func add_action(action):
	last_action_time = 0
	if(not ACTIONS.has(action)):
		ACTIONS.append(action)


func _physics_process(delta):
	#print(ACTIONS)
	# Increment counters
	shoot_time += delta
	last_action_time += delta

	if(last_action_time > COMBINATION_TIMING_TRESHOLD):
		last_action_time = 0
		ACTIONS = []

	### MOVEMENT ###

	# Apply gravity
	linear_vel += delta * GRAVITY_VEC
	# Move and slide
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	# Detect if we are on floor - only works if called *after* move_and_slide
	var on_floor = is_on_floor()

	if is_on_floor():
		MULTI_JUMP = MAX_MULTI_JUMP
		DASHING = false
		DASHING_TIME = 0
		CAN_DASH = true

	### CONTROL ###

	# Horizontal movement
	var target_speed = 0
	if Input.is_action_just_pressed("move_left"):
		add_action("left")
	if Input.is_action_just_pressed("move_right"):
		add_action("right")

	if Input.is_action_pressed("move_left") and not DASHING:
		target_speed -= 1
		FACING = -1
	if Input.is_action_pressed("move_right") and not DASHING:
		add_action("right")
		target_speed += 1
		FACING = 1

	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)

	# Jumping
	#if on_floor and Input.is_action_just_pressed("jump") :
	if Input.is_action_just_pressed("jump") :
		add_action("jump")
		if on_floor:
			linear_vel.y = -JUMP_SPEED
			($SoundJump as AudioStreamPlayer2D).play()
		else:
			if(MULTI_JUMP > 0):
				CAN_DASH = true
				linear_vel.y = -JUMP_SPEED
				($SoundJump as AudioStreamPlayer2D).play()
				MULTI_JUMP -= 1


	# Shooting
	if Input.is_action_just_pressed("shoot"):
		add_action("shoot")
		var bullet = Bullet.instance()
		bullet.position = ($Sprite/BulletShoot as Position2D).global_position # use node for shoot position
		bullet.linear_velocity = Vector2(sprite.scale.x * BULLET_VELOCITY, 0)
		bullet.add_collision_exception_with(self) # don't want player to collide with bullet
		get_parent().add_child(bullet) # don't want bullet to move with me, so add it as child of parent
		($SoundShoot as AudioStreamPlayer2D).play()
		shoot_time = 0

	### ANIMATION ###

	var new_anim = "idle"

	if on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			sprite.scale.x = -1
			new_anim = "run"

		if linear_vel.x > SIDING_CHANGE_SPEED:
			sprite.scale.x = 1
			new_anim = "run"
	else:
		# We want the character to immediately change FACING side when the player
		# tries to change direction, during air control.
		# This allows for example the player to shoot quickly left then right.
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right") and not DASHING:
			sprite.scale.x = -1
		if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left") and not DASHING:
			sprite.scale.x = 1

		if Input.is_key_pressed(KEY_X) and CAN_DASH:
			DASHING = true
			CAN_DASH = false

		if linear_vel.y < 0:
			new_anim = "jumping"
		else:
			new_anim = "falling"

		if DASHING:
			DASHING_TIME += delta
			linear_vel.x = FACING * RUN_SPEED
			linear_vel.y = -15 # why???

			if DASHING_TIME > MAX_DASHING_TIME:
				DASHING = false
				DASHING_TIME = 0

	if shoot_time < SHOOT_TIME_SHOW_WEAPON:
		new_anim += "_weapon"

	if new_anim != anim:
		anim = new_anim
		($Anim as AnimationPlayer).play(anim)
