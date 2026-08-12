extends Node2D
@export var despawn_timer : Timer
var explosion_particle_fx: Array = []

func _ready() -> void:
	explosion_particle_fx = get_children().filter(
		func(child): return child.is_in_group("explosion_particles"))
	
	var max_lifetime := 0.0
	for particle_fx in explosion_particle_fx:
		particle_fx.restart()
		max_lifetime = max(max_lifetime, particle_fx.lifetime)
	
	despawn_timer.wait_time = max_lifetime
	despawn_timer.start()

func _on_despawn_timer_timeout() -> void:
	queue_free()
