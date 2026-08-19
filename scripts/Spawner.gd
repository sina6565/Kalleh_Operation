extends Node

# Simple Spawner if project wants a dedicated node
@export var obstacle_scene: PackedScene
@export var collectible_scene: PackedScene
@export var spawn_interval: float = 1.2
@export var spawn_z: float = -30.0
@export var lanes: PackedFloat32Array = PackedFloat32Array([-2.0, 0.0, 2.0])

var _timer: float = 0.0

func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_timer = spawn_interval
		_spawn()

func _spawn() -> void:
	var lane = lanes[randi() % lanes.size()]
	if randi() % 100 < 65 and obstacle_scene:
		var o = obstacle_scene.instantiate()
		if o:
			o.global_transform.origin = Vector3(lane, 0.5, spawn_z)
			get_tree().get_current_scene().add_child(o)
	else:
		if collectible_scene:
			var c = collectible_scene.instantiate()
			if c:
				c.global_transform.origin = Vector3(lane, 0.5, spawn_z)
				get_tree().get_current_scene().add_child(c)
