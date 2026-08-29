extends CharacterBody3D

# Three-lane runner Player controller for Godot 4.x
# - Uses CharacterBody3D.velocity provided by engine
# - Exports and @onready where appropriate

signal collected(what)
signal hit(damage)
signal landed()
signal jumped()

@export var lane_positions: PackedFloat32Array = PackedFloat32Array([-2.0, 0.0, 2.0])

@export var forward_speed: float = 12.0
@export var lane_change_speed: float = 10.0
@export var jump_speed: float = 8.5
@export var gravity: float = 20.0

var current_lane: int = 1
var is_jumping: bool = false

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	current_lane = clamp(current_lane, 0, lane_positions.size() - 1)

func _physics_process(delta: float) -> void:
	# forward movement (negative z is forward)
	velocity.z = -forward_speed

	# gravity applied to velocity.y
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if is_jumping:
			is_jumping = false
			emit_signal("landed")
			if anim and anim.has_animation("land"):
				anim.play("land")
			velocity.y = 0.0

	# lateral (x) - drive velocity.x toward target lane position
	var target_x: float = lane_positions[current_lane]
	var desired_x_vel = (target_x - global_transform.origin.x) / max(delta, 0.001)
	velocity.x = lerp(velocity.x, desired_x_vel, clamp(lane_change_speed * delta, 0.0, 1.0))

	# Move using CharacterBody3D's API: move_and_slide() operates on self.velocity
	move_and_slide()

	# Animation: run when on floor
	if is_on_floor() and not is_jumping:
		if anim and anim.has_animation("run") and not anim.is_playing():
			anim.play("run")

func change_lane(direction: int) -> void:
	var new_lane: int = clamp(current_lane + direction, 0, lane_positions.size() - 1)
	if new_lane == current_lane:
		return
	current_lane = new_lane
	if anim and anim.has_animation("turn"):
		anim.play("turn")

func jump() -> void:
	if not is_on_floor():
		return
	is_jumping = true
	velocity.y = jump_speed
	emit_signal("jumped")
	if anim and anim.has_animation("jump"):
		anim.play("jump")

func _unhandled_input(event) -> void:
	if event is InputEventKey and event.pressed:
		if Input.is_action_just_pressed("ui_left"):
			change_lane(-1)
		elif Input.is_action_just_pressed("ui_right"):
			change_lane(1)
		elif Input.is_action_just_pressed("ui_accept"):
			jump()

# Collision hooks
func _on_body_entered(body: Node) -> void:
	if body and body.has_method("collect"):
		body.collect(self)
		emit_signal("collected", body)
	elif body and body.has_method("hit_player"):
		body.hit_player(self)
		emit_signal("hit", 1)
