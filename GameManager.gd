extends Node

# سیگنال‌ها برای ارتباطِ ماژولار
signal health_updated(new_health)
signal game_over

# متغیرهای تنظیمات
var speed: float = 12.0
var gravity: float = 20.0

# وضعیتِ بازی (Game State)
var health: int = 2
var is_game_running: bool = true

func take_damage() -> void:
	if not is_game_running: return
	
	health -= 1
	health_updated.emit(health)
	
	if health <= 0:
		trigger_game_over()

func trigger_game_over() -> void:
	is_game_running = false
	game_over.emit()
	print("Game Over triggered by GameManager")
