extends CharacterBody3D

@export var lanes = [-4.0, 0.0, 4.0]
@export var lateral_speed = 10.0
@export var forward_speed = 8.0

var current_lane := 1
var target_x := 0.0
var score := 0

func _ready():
	# initialize target x to middle lane
	target_x = lanes[current_lane]

func _process(delta):
	# input handling for lane changes
	if Input.is_action_just_pressed("ui_left"):
		if current_lane > 0:
			current_lane -= 1
			target_x = lanes[current_lane]
	elif Input.is_action_just_pressed("ui_right"):
		if current_lane < lanes.size() - 1:
			current_lane += 1
			target_x = lanes[current_lane]

func _physics_process(delta):
	var vel = velocity
	# automatic forward movement (negative Z)
	vel.z = -forward_speed
	# smooth lateral movement towards target x
	var dx = target_x - global_transform.origin.x
	# simple proportional controller
	vel.x = clamp(dx * lateral_speed, -lateral_speed, lateral_speed)
	velocity = vel
	move_and_slide()

func reset_position():
	# helper to reset player when restarting prototype
	global_transform.origin = Vector3(0, 0.5, 0)
	velocity = Vector3.ZERO
	current_lane = 1
	target_x = lanes[current_lane]
	score = 0

