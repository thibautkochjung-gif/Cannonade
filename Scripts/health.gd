extends Node2D

@export var max_health = 100.0

var current_health : float
signal health_depleted
signal health_changed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func take_damage(amount: int, hit_direction: Vector2 = Vector2.ZERO):
	current_health = current_health - amount
	health_changed.emit(amount/max_health, hit_direction)
	if current_health <= 0:
		health_depleted.emit()
