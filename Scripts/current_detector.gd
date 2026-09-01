extends Area2D
class_name CurrentDetector

var _active_currents: Array[Current] = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _on_area_entered(area: Area2D) -> void:
	if area is Current:
		_active_currents.append(area)


func _on_area_exited(area: Area2D) -> void:
	if area is Current:
		_active_currents.erase(area)


func get_total_push(global_pos: Vector2) -> Vector2:
	var total := Vector2.ZERO
	for current in _active_currents:
		if is_instance_valid(current):
			total += current.get_push_at(global_pos)
	return total
