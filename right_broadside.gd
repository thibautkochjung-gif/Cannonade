extends Node2D

@export var shot_delay_max = 0.2
@export var shot_strength = 700

var cannon_count: int
var cannon_ready_count: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cannon_count = get_children().filter(func(child): return child.is_in_group("cannon")).size()
	cannon_ready_count = cannon_count
	
func fire():
	for cannon in get_children():
		var delay = randf_range(0.0, shot_delay_max)
		get_tree().create_timer(delay).timeout.connect(func(): cannon.cannon_fire(self))
	cannon_ready_count = 0
	
func _on_cannon_cannon_ready() -> void:
	cannon_ready_count += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print("Cannons ready: ", cannon_ready_count)
