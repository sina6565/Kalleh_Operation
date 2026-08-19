extends Area3D

func _ready():
	randomize()
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is CharacterBody3D:
		print("Player hit obstacle - prototype: restarting scene")
		get_tree().reload_current_scene()

func _process(delta):
	# optional: slowly rotate obstacle for visual feedback
	rotation_degrees.y += 30 * delta

