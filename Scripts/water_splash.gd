extends Node2D

func _ready():
	var tween = create_tween()
	
	var start_scale = randf_range(0.8, 1)
	var end_scale = randf_range(2, 4)
	var time_to_grow = 2.0

	$WaterRingSprite.scale = Vector2(start_scale, start_scale)
	
	tween.parallel().tween_property(
		$WaterRingSprite,
		"scale",
		Vector2(end_scale, end_scale),
		time_to_grow
	)

	tween.parallel().tween_property(
		$WaterRingSprite,
		"modulate:a",
		0.0,
		time_to_grow
	)

	await tween.finished
	queue_free()
