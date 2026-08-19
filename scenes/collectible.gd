extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is CharacterBody3D:
		if body.has_method("score"):
			# safety: if score is a property
			pass
		# try incrementing score property directly
		if "score" in body:
			body.score += 1
		print("Collected! Player score: ", body.score)
		queue_free()

func _process(delta):
	# rotate for visibility
	rotation_degrees.y += 120 * delta

