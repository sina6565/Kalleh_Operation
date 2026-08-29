extends Area3D

@export var value: int = 10

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body and body.has_method("collect"):
		collect(body)

func collect(player: Node) -> void:
	# inform player or game manager by freeing and emitting a signal
	if Engine.has_singleton("GameManager"):
		var gm = GameManager
		if gm and gm.has_method("add_score"):
			gm.add_score(value)
	queue_free()
