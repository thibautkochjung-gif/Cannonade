extends TextureProgressBar
class_name  RightBroadsideIndicator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = max_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_reload_indicator(percent: float) -> void:
	print("setting reload indic to ", percent)
	value = percent * max_value
