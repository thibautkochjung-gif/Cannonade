extends Node2D
@export var despawn_timer : Timer
@onready var particles: GPUParticles2D = $DamageParticleFX

func setup(direction: Vector2) -> void:
	particles.rotation = direction.angle()
	particles.restart()
	
	despawn_timer.wait_time = particles.lifetime
	despawn_timer.start()

func _on_despawn_timer_timeout() -> void:
	queue_free()
