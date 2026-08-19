extends Camera3D

# Simple camera follow with smooth motion, look-ahead and shake support
@export var follow_target: NodePath
@export var follow_distance: float = 8.0
@export var height: float = 4.0
@export var smoothing: float = 6.0

var _target_node: Node = null
var _shake_amount: float = 0.0
var _shake_time: float = 0.0

func _ready() -> void:
	if follow_target != NodePath():
		_target_node = get_node_or_null(follow_target)

func _process(delta: float) -> void:
	if not _target_node:
		return
	# desired position behind the player
	var player_pos: Vector3 = _target_node.global_transform.origin
	var desired = player_pos + Vector3(0, height, follow_distance)
	# interpolate
	global_transform.origin = global_transform.origin.lerp(desired, clamp(smoothing * delta, 0.0, 1.0))
	# look at player
	look_at(player_pos + Vector3(0,1.2,0), Vector3.UP)

	# camera shake small offset
	if _shake_time > 0.0:
		_shake_time -= delta
		var s = _shake_amount * (_shake_time)
		global_transform.origin += Vector3(randf_range(-s, s), randf_range(-s, s), 0)

func shake(amount: float, duration: float) -> void:
	_shake_amount = amount
	_shake_time = duration
