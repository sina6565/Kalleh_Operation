extends Node

# Central game manager (improved). Keeps backward compatibility with existing signals.
signal health_updated(new_health)
signal game_over
signal score_updated(new_score)

@export var player_scene: PackedScene
@export var obstacle_scene: PackedScene
@export var collectible_scene: PackedScene
@export var spawn_interval: float = 1.0
@export var spawn_distance: float = -30.0

var speed: float = 12.0
var gravity: float = 20.0
var health: int = 2
var is_game_running: bool = true
var score: int = 0

var _spawn_timer: float = 0.0

func _ready() -> void:
	# keep existing behavior
	pass

func take_damage() -> void:
	if not is_game_running: return

	health -= 1
	emit_signal("health_updated", health)

	if health <= 0:
		trigger_game_over()

func trigger_game_over() -> void:
	is_game_running = false
	emit_signal("game_over")
	print("Game Over triggered by GameManager")

# Score and collectibles
func add_score(amount: int) -> void:
	score += amount
	emit_signal("score_updated", score)

# Basic spawner: instances obstacles or collectibles ahead of player
func _process(delta: float) -> void:
	if not is_game_running: return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = spawn_interval
		_spawn_random_entity()

func _spawn_random_entity() -> void:
	# choose lane
	var lanes = [-2.0, 0.0, 2.0]
	var lane = lanes[randi() % lanes.size()]
	# choose obstacle or collectible
	if randi() % 100 < 60 and obstacle_scene: # 60% obstacle
		var o = obstacle_scene.instantiate()
		if o and o is Node3D:
			o.global_transform.origin = Vector3(lane, 0.5, spawn_distance)
			get_tree().get_current_scene().add_child(o)
	else:
		if collectible_scene:
			var c = collectible_scene.instantiate()
			if c and c is Node3D:
				c.global_transform.origin = Vector3(lane, 0.5, spawn_distance)
				get_tree().get_current_scene().add_child(c)
