extends Area2D
class_name Current

@export var push_speed: float = 40.0

@onready var flow_markers: Node2D = $FlowMarkers


## Direction the current pushes toward at a given world position,
## found by nearest FlowMarker (each marker's rotation is the local
## downstream direction, hand-set in the editor for this shape).
func get_push_at(global_pos: Vector2) -> Vector2:
	if flow_markers.get_child_count() == 0:
		push_warning("Current '%s' has no FlowMarkers - pushing nowhere" % name)
		return Vector2.ZERO

	var closest: Marker2D = flow_markers.get_child(0)
	var closest_dist: float = closest.global_position.distance_squared_to(global_pos)

	for marker in flow_markers.get_children():
		var d: float = marker.global_position.distance_squared_to(global_pos)
		if d < closest_dist:
			closest = marker
			closest_dist = d

	return Vector2.RIGHT.rotated(closest.global_rotation) * push_speed
