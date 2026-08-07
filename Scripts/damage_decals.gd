extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_health_ratio(ratio: float) -> void:
	$DamageDecal1.visible = ratio <= 0.66
	$DamageDecal2.visible = ratio <= 0.33
	$DamageDecal3.visible = ratio <= 0.1
