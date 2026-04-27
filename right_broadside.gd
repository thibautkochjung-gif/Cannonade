extends Node2D

@export var shot_delay_range = 0.3
@export var shot_strength = 100
@export var cannonball_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func fire():
	for marker in get_children():
		var delay = randf_range(0.0, shot_delay_range)
		get_tree().create_timer(delay).timeout.connect(func(): _spawn_cannonball(marker))


func _spawn_cannonball(marker):
	var cannonball = cannonball_scene.instantiate()
	cannonball.global_position = marker.global_position
	cannonball.player = self.get_parent()
	cannonball.broadside = self
	get_tree().root.add_child(cannonball)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
