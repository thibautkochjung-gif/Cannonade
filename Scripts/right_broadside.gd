extends Node2D
class_name RightBroadside

@export var shot_delay_max = 0.2
@export var shot_strength = 700


var cannon_count: int
var cannon_ready_count: int
var cannon_ready_percentage: float

signal fired(amount: int, direction: Vector2)
signal reload_percentage_changed(new_percentage)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cannon_count = get_children().size()
	cannon_ready_count = cannon_count
	cannon_ready_percentage = float(cannon_ready_count) / cannon_count
	for cannon in get_children():
		cannon.ready_to_fire_signal.connect(_on_cannon_ready)

	
func fire():
	for cannon in get_children():
		var delay = randf_range(0.0, shot_delay_max)
		get_tree().create_timer(delay).timeout.connect(func(c = cannon): c.cannon_fire(self))
	fired.emit(cannon_ready_count, -global_transform.y)
	cannon_ready_count = 0
	reload_percentage_changed.emit(0.0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cannon_ready() -> void:
	cannon_ready_count += 1
	cannon_ready_percentage = float(cannon_ready_count) / cannon_count
	reload_percentage_changed.emit(cannon_ready_percentage)
