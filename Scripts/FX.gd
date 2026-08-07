extends Node

signal screenshake_requested(amount: float)
signal recoil_requested(amount: float, direction: Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#func spawn_hit_effect(pos: Vector2, direction: Vector2) -> void:
#    var effect = HIT_EFFECT_SCENE.instantiate()
#    get_tree().current_scene.add_child(effect)
#    effect.global_position = pos
#    effect.play(direction)


func shake(amount: float, direction: Vector2 = Vector2.ZERO) -> void:
	screenshake_requested.emit(amount, direction)
	
func recoil(amount: int, direction: Vector2 = Vector2.ZERO) -> void:
	recoil_requested.emit(amount, direction)
