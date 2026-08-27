extends Node

signal objective_completed
signal objective_failed

func setup(_objective_data: ObjectiveData) -> void:
	var enemies := get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		objective_completed.emit()
		return
	for enemy in enemies:
		enemy.died.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	if get_tree().get_nodes_in_group("enemy").is_empty():
		objective_completed.emit()
