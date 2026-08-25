extends TextureRect

@export var MastStateIcons: Array[Texture2D]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_mast_state(new_state: int) -> void:
	texture = MastStateIcons[new_state]
