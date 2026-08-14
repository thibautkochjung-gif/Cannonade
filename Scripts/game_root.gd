extends Node

func _ready() -> void:
	GameManagerScene.register_enemies()
	GameManagerScene.world_root = self
