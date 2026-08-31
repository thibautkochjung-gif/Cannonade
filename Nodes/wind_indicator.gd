extends TextureRect
class_name WindIndicator

## Rotates to match the wind's current direction and scales with wind
## strength. Wired up in HUD._ready() - unlike the other indicators this
## doesn't need connect_to_player(), since Wind is a global autoload
## rather than something that lives on the player.

@export var min_scale: float = 0.6
@export var max_scale: float = 1.4


func _ready() -> void:
	pivot_offset = size / 2.0  # rotate/scale around the icon's center, not its corner


func update_wind(direction: Vector2, speed: float) -> void:
	rotation = direction.angle()
	var strength : float = clamp(speed / Wind.max_wind_speed, 0.0, 1.0)
	var s : float = lerp(min_scale, max_scale, strength)
	scale = Vector2(s, s)
