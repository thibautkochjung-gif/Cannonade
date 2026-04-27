extends Node2D

@export var cannonball_scene : PackedScene
@export var broadside : Node2D

var player : CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent().get_parent()

func cannon_fire():
	var cannonball = cannonball_scene.instantiate()
	cannonball.global_position = global_position
	cannonball.player = player
	cannonball.broadside = broadside
	get_tree().root.add_child(cannonball)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
