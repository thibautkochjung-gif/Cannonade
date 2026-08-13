extends Sprite2D

var spin_speed: float = 0.0

func configure(texture_in: Texture2D, spin_range: Vector2, scale_modifier: Vector2) -> void:
	texture = texture_in
	scale = scale_modifier
	if spin_range != Vector2.ZERO:
		spin_speed = randf_range(spin_range.x, spin_range.y)
		spin_speed *= -1.0 if randf() < 0.5 else 1.0
		rotation = randf_range(0.0, TAU)  # random starting phase too
	else:
		spin_speed = 0.0
		rotation = 0.0

func _process(delta: float) -> void:
	if spin_speed != 0.0:
		rotation += spin_speed * delta
