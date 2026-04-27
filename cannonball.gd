extends RigidBody2D

@export var player : CharacterBody2D
@export var broadside : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_impulse( broadside.global_transform.y * broadside.shot_strength + player.velocity)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
