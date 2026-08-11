extends Node2D

@onready var water_ring: Sprite2D = $WaterRingSprite
@onready var droplet_particles: GPUParticles2D = $DropletParticles



func setup(water_ring_size : float, particle_multiplier : float) -> void :

	var tween = create_tween()
	
	var start_scale = randf_range(0.8, 1) * water_ring_size
	var end_scale = randf_range(2, 4) * water_ring_size
	var time_to_grow = 2.0

	$WaterRingSprite.scale = Vector2(start_scale, start_scale)
	
	droplet_particles.amount = droplet_particles.amount * particle_multiplier
	
	
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
	
