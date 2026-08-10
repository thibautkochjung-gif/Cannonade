class_name SailCondition
extends Node

@export var max_condition: float = 100.0

var condition: float


func _ready() -> void:
	condition = max_condition
	

func take_damage(amount: float) -> void:
	condition = max(condition - amount, 0.0)
	

func get_condition_ratio() -> float:
	return condition / max_condition
	

func get_speed_multiplier() -> float:
	return lerp(0.5, 1.0, get_condition_ratio())
	
func get_turn_multiplier() -> float:
	return lerp(0.6, 1.0, get_condition_ratio())
