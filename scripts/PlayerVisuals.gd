extends Node3D

# Visual behavior controller for the procedural Penguin placeholder
# - Connects to Player signals (jumped, landed, hit, collected)
# - Applies procedural bobbing, wing flaps and simple reactions so the mascot feels alive

onready var _player := get_parent().get_parent() if get_parent() else null
onready var body := $Body
onready var left_wing := $LeftWing
onready var right_wing := $RightWing
onready var head := $Head

var _time: float = 0.0
var _state: String = "run"

func _ready() -> void:
	# Connect to Player signals if available
	if _player:
		if _player.has_signal("jumped"):
			_player.connect("jumped", Callable(self, "_on_player_jumped"))
		if _player.has_signal("landed"):
			_player.connect("landed", Callable(self, "_on_player_landed"))
		if _player.has_signal("hit"):
			_player.connect("hit", Callable(self, "_on_player_hit"))
		if _player.has_signal("collected"):
			_player.connect("collected", Callable(self, "_on_player_collected"))

	set_physics_process(true)

func _physics_process(delta: float) -> void:
	_time += delta
	# Determine state based on player's floor/jump status when possible
	if _player:
		if _player.has_method("is_on_floor") and _player.has_method("is_jumping"):
			# Player.gd exposes is_jumping variable, but not as method; use properties if present
			# we'll try to read it safely
			var on_floor := false
			var jumping := false
			if _player.has_method("is_on_floor"):
				on_floor = _player.is_on_floor()
			if _player.has_variable("is_jumping"):
				jumping = _player.get("is_jumping")
			if on_floor and not jumping:
				_state = "run"
			else:
				_state = "jump"
	else:
		_state = "run"

	# Procedural animations
	if _state == "run":
		# subtle up-down bob and wing flap
		var bob = 0.03 * sin(_time * 18.0)
		var target_y = 0.9 + bob
		var t = 8.0 * delta
		var cur = body.transform
		cur.origin.y = lerp(cur.origin.y, target_y, t)
		body.transform = cur

		left_wing.rotation_degrees.x = lerp(left_wing.rotation_degrees.x, 20.0 * sin(_time * 24.0), 0.2)
		right_wing.rotation_degrees.x = lerp(right_wing.rotation_degrees.x, -20.0 * sin(_time * 24.0), 0.2)
		# face nod
		head.rotation_degrees.x = lerp(head.rotation_degrees.x, 5.0 * sin(_time * 6.0), 0.05)

	elif _state == "jump":
		# raise body a bit while in air
		var cur2 = body.transform
		cur2.origin.y = lerp(cur2.origin.y, 1.2, 0.2)
		body.transform = cur2
		left_wing.rotation_degrees.x = lerp(left_wing.rotation_degrees.x, -40.0, 0.3)
		right_wing.rotation_degrees.x = lerp(right_wing.rotation_degrees.x, -40.0, 0.3)

func _on_player_jumped() -> void:
	# immediate jump pose
	left_wing.rotation_degrees.x = -60.0
	right_wing.rotation_degrees.x = -60.0
	# quick head tilt
	head.rotation_degrees.x = -15.0

func _on_player_landed() -> void:
	# landing reaction: quick squat then recover
	var cur = body.transform
	cur.origin.y = 0.6
	body.transform = cur
	# slight wing recoil
	left_wing.rotation_degrees.x = -30.0
	right_wing.rotation_degrees.x = -30.0
	# schedule recovery
	yield(get_tree().create_timer(0.15), "timeout")
	# recover to run pose

func _on_player_hit(damage = 1) -> void:
	# recoil and head shake
	body.rotate_x(deg2rad(-10))
	head.rotation_degrees.y = 20.0
	yield(get_tree().create_timer(0.25), "timeout")
	# recover
	body.rotation_degrees.x = lerp(body.rotation_degrees.x, 0.0, 0.4)
	head.rotation_degrees.y = lerp(head.rotation_degrees.y, 0.0, 0.4)

func _on_player_collected(item) -> void:
	# small celebration bounce
	body.translate_object_local(Vector3(0, 0.08, 0))
	yield(get_tree().create_timer(0.12), "timeout")
	body.translate_object_local(Vector3(0, -0.08, 0))
