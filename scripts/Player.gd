extends CharacterBody3D

# Three-lane runner Player controller for Godot 4.x
# - Keep gameplay separate from visuals so the 3D character model can be swapped later
# - Exports allow tuning without changing logic

signal collected(what)
signal hit(damage)
signal landed()
signal jumped()

@export_var
var lane_positions: PackedFloat32Array = PackedFloat32Array([-2.0, 0.0, 2.0])

@export var forward_speed: float = 12.0
@export var lane_change_speed: float = 10.0
@export var jump_speed: float = 8.5
@export var gravity: float = 20.0

var current_lane: int = 1
var velocity: Vector3 = Vector3.ZERO
var is_jumping: bool = false

onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# ensure lane index is sane
	current_lane = clamp(current_lane, 0, lane_positions.size() - 1)
	velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	# forward movement
	velocity.z = -forward_speed

	# gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if is_jumping:
			# landed this frame
			is_jumping = false
			emit_signal("landed")
			if anim.has_animation("land"):
				anim.play("land")

	# lateral (x) movement toward target lane
	var target_x: float = lane_positions[current_lane]
	var new_x: float = lerp(global_transform.origin.x, target_x, clamp(lane_change_speed * delta, 0.0, 1.0))
	var lateral_move: Vector3 = Vector3(new_x - global_transform.origin.x, 0, 0)

	# compose motion. CharacterBody3D uses move_and_slide-like API
	var move_vec: Vector3 = Vector3(lateral_move.x, velocity.y * delta, velocity.z * delta)
	# Use built-in velocity for move_and_slide_with_snap pattern
	# Simpler: translate by lateral and forward/vertical via move_and_collide
	# We'll use move_and_slide for reliable floor detection
	velocity.x = (new_x - global_transform.origin.x) / max(delta, 0.001)
	velocity.z = -forward_speed
	velocity = move_and_slide(velocity, Vector3.UP)

	# Animation: run when on floor
	if is_on_floor() and not is_jumping:
		if anim.has_animation("run") and not anim.is_playing():
			anim.play("run")

func change_lane(direction: int) -> void:
	# direction: -1 left, +1 right
	var new_lane: int = clamp(current_lane + direction, 0, lane_positions.size() - 1)
	if new_lane == current_lane:
		return
	current_lane = new_lane
	# play turn animation
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

# Input mapping wrapper (call from main scene input or connect to UI)
func _input(event) -> void:
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("ui_left"):
			change_lane(-1)
		elif event.is_action_pressed("ui_right"):
			change_lane(1)
		elif event.is_action_pressed("ui_accept"):
			jump()

# Hooks for collisions with Collectibles and Obstacles
func _on_body_entered(body: Node) -> void:
	if body.has_method("collect"):
		body.collect(self)
		emit_signal("collected", body)
	elif body.has_method("hit_player"):
		body.hit_player(self)
		emit_signal("hit", 1)
