extends Label
class_name SurvivalTimerLabel

func update_time(total_seconds: int) -> void:
	text = GameManagerScene.format_time(total_seconds)
