extends Node

const SPAWN_POINT_GROUP := "enemy_spawn_point"

func spawn_all(enemy_scenes: Array[PackedScene]) -> void:
	var spawn_points := get_tree().get_nodes_in_group(SPAWN_POINT_GROUP)
	if spawn_points.is_empty():
		push_warning("EnemySpawner: no nodes in group '%s' - nothing spawned" % SPAWN_POINT_GROUP)
		return

	spawn_points.shuffle()

	for i in enemy_scenes.size():
		var spawn_point: Node2D = spawn_points[i % spawn_points.size()]
		var enemy := enemy_scenes[i].instantiate()
		get_parent().add_child(enemy)
		enemy.global_position = spawn_point.global_position
		enemy.global_rotation = spawn_point.global_rotation
