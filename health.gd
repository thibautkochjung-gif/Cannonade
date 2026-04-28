extends Node2D

@export var max_health = 100

var current_health : int
signal health_depleted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func take_damage(amount: int):
	current_health = current_health-amount
	if current_health <= 0:
		print("DIEDED")
		emit_signal("health_depleted")
