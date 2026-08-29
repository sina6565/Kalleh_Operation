extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var health_label: Label = $HealthLabel

func set_score(value: int) -> void:
	score_label.text = "Score: %d" % value

func set_health(value: int) -> void:
	health_label.text = "Health: %d" % value

func show_game_over() -> void:
	score_label.text = score_label.text + "  [GAME OVER]"
