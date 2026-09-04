extends Area2D
class_name CurrentDetector

## Optional. Shapes how strongly a current's push applies based on the angle
## between the ship's heading and the push direction - same convention as
## Wind's own direction curves: X = 0 when the push is fully aligned with
## the ship's heading, X = 1 when it's fully opposed. Leave unset to get
## every current's push at flat, undirected strength (e.g. on the enemy's
## detector, which shouldn't have this behavior).
@export var alignment_response_curve: Curve

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


## ship_forward is optional - omit it to get every current's push at full
## strength regardless of direction.
func get_total_push(global_pos: Vector2, ship_forward: Vector2 = Vector2.ZERO) -> Vector2:
	var total := Vector2.ZERO
	for current in _active_currents:
		if not is_instance_valid(current):
			continue
		var push: Vector2 = current.get_push_at(global_pos)
		total += push * _alignment_multiplier(push, ship_forward)
	return total


func _alignment_multiplier(push: Vector2, ship_forward: Vector2) -> float:
	if alignment_response_curve == null or push == Vector2.ZERO or ship_forward == Vector2.ZERO:
		return 1.0
	var angle_t : float = abs(ship_forward.angle_to(push)) / PI
	return alignment_response_curve.sample(angle_t)
