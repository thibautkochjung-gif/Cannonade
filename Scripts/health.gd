extends Node2D
class_name Health

@export var max_health = 100.0

var current_health : float
signal health_depleted
signal health_changed(amount, max_health, current_health, hit_direction, source, fx_trigger_chance)

func _ready() -> void:
	current_health = max_health
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass


func take_damage(amount: float, hit_direction: Vector2, source: String = "cannon", fx_trigger_chance: float = 1.0) -> void:
	var ship := get_parent()
	var mitigation: float = RunState.get_directional_damage_taken_multiplier(ship, hit_direction)
	var final_amount := amount * mitigation
	
	current_health = current_health - final_amount
	health_changed.emit(final_amount, max_health, current_health, hit_direction, source, fx_trigger_chance)
	if current_health <= 0:
		health_depleted.emit()
