extends Node3D

@export var spawn_interval := 1.2
@export var lanes = [-4.0, 0.0, 4.0]
@export var obstacle_scene: PackedScene
@export var collectible_scene: PackedScene

var time_acc := 0.0
onready var player = $PlayerInstance

func _ready():
	# load packed scenes (already assigned via ext_resource in tscn, but keep for safety)
	obstacle_scene = preload("res://scenes/obstacle.tscn")
	collectible_scene = preload("res://scenes/collectible.tscn")

func _process(delta):
	# simple spawner that spawns an obstacle or collectible ahead of the player
	time_acc += delta
	if time_acc >= spawn_interval:
		time_acc = 0.0
		_spawn_random()

	# position camera to follow player (smooth)
	var cam = $Camera
	var desired = player.global_transform.origin + Vector3(0, 6, 12)
	cam.global_transform.origin = cam.global_transform.origin.linear_interpolate(desired, 0.15)
	cam.look_at(player.global_transform.origin + Vector3(0,1,0))

func _spawn_random():
	var lane_idx = randi() % lanes.size()
	var lane_x = lanes[lane_idx]
	# choose randomly obstacle or collectible
	if randf() < 0.6:
		# spawn obstacle
		var ob = obstacle_scene.instantiate()
		add_child(ob)
		ob.global_transform.origin = Vector3(lane_x, 0.5, player.global_transform.origin.z - 60 - randf() * 40)
	else:
		var col = collectible_scene.instantiate()
		add_child(col)
		col.global_transform.origin = Vector3(lane_x, 0.4, player.global_transform.origin.z - 50 - randf() * 30)

