extends Node3D

# Visual behavior controller for the procedural Penguin placeholder

@onready var body := $Body
@onready var left_wing := $LeftWing
@onready var right_wing := $RightWing
@onready var head := $Head

var _time: float = 0.0
var _state: String = "run"
var _player: Node = null

func _ready() -> void:
	# Find nearest CharacterBody3D ancestor (the Player)
	var p = get_parent()
	while p:
		if p is CharacterBody3D:
			_player = p
			break
		p = p.get_parent()

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
	if _player:
		if _player.has_method("is_on_floor"):
			if _player.is_on_floor():
				_state = "run"
			else:
				_state = "jump"
	else:
		_state = "run"

	# Procedural animations
	if _state == "run":
		var bob = 0.03 * sin(_time * 18.0)
		var target_y = 0.9 + bob
		var t = 8.0 * delta
		var cur = body.transform
		cur.origin.y = lerp(cur.origin.y, target_y, t)
		body.transform = cur

		left_wing.rotation_degrees.x = lerp(left_wing.rotation_degrees.x, 20.0 * sin(_time * 24.0), 0.2)
		right_wing.rotation_degrees.x = lerp(right_wing.rotation_degrees.x, -20.0 * sin(_time * 24.0), 0.2)
		head.rotation_degrees.x = lerp(head.rotation_degrees.x, 5.0 * sin(_time * 6.0), 0.05)

	elif _state == "jump":
		var cur2 = body.transform
		cur2.origin.y = lerp(cur2.origin.y, 1.2, 0.2)
		body.transform = cur2
		left_wing.rotation_degrees.x = lerp(left_wing.rotation_degrees.x, -40.0, 0.3)
		right_wing.rotation_degrees.x = lerp(right_wing.rotation_degrees.x, -40.0, 0.3)

func _on_player_jumped() -> void:
	left_wing.rotation_degrees.x = -60.0
	right_wing.rotation_degrees.x = -60.0
	head.rotation_degrees.x = -15.0

func _on_player_landed() -> void:
	var cur = body.transform
	cur.origin.y = 0.6
	body.transform = cur
	left_wing.rotation_degrees.x = -30.0
	right_wing.rotation_degrees.x = -30.0
	# schedule recovery using await
	await get_tree().create_timer(0.15).timeout

func _on_player_hit(damage = 1) -> void:
	# recoil and head shake
	body.rotate_x(deg2rad(-10))
	head.rotation_degrees.y = 20.0
	await get_tree().create_timer(0.25).timeout
	# recover (smooth)
	body.rotation_degrees.x = lerp(body.rotation_degrees.x, 0.0, 0.4)
	head.rotation_degrees.y = lerp(head.rotation_degrees.y, 0.0, 0.4)

func _on_player_collected(item) -> void:
	body.translate_object_local(Vector3(0, 0.08, 0))
	await get_tree().create_timer(0.12).timeout
	body.translate_object_local(Vector3(0, -0.08, 0))
