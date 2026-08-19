extends StaticBody3D

@export var damage: int = 1

func hit_player(player: Node) -> void:
	if player.has_method("take_damage"):
		player.take_damage()
	if get_tree():
		queue_free()
