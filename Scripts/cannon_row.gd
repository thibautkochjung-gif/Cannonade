class_name CannonRow
extends Node2D

@export var cannon_scene: PackedScene
@export var cannon_count: int = 5
@export var start_point: Vector2 = Vector2.ZERO
@export var end_point: Vector2 = Vector2.RIGHT * 10.0
@export var cannon_rotation: float = PI / 2.0

func _ready() -> void:
	_spawn_cannons()


func _spawn_cannons() -> void:
	for i in cannon_count:
		var t: float = 0.5 if cannon_count == 1 else float(i) / float(maxi(cannon_count - 1, 1))
		var cannon = cannon_scene.instantiate()
		cannon.position = start_point.lerp(end_point, t)
		cannon.rotation = cannon_rotation
		add_child(cannon)
