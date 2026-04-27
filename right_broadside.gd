extends Node2D

@export var shot_delay_max = 0.2
@export var shot_strength = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func fire():
	for cannon in get_children():
		var delay = randf_range(0.0, shot_delay_max)
		get_tree().create_timer(delay).timeout.connect(func(): cannon.cannon_fire())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
