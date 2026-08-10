extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func is_over_land(world_position: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = world_position
	query.collision_mask = 1 << 5  # bit for layer 6 (layers are 1-indexed in editor, 0-indexed as bits)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	
	var results = space_state.intersect_point(query, 1)  # 1 = max results needed, we only need to know if ANY hit exists
	return results.size() > 0
