extends RigidBody2D

@export var ship : Node2D
@export var broadside : Node2D
@export var shot_strength_variance = 0.1
@export var despawn_timer : Timer
@export var splash_scene : PackedScene
@export var despawn_time_variance = 0.5
@export var damage_fx_scene : PackedScene
@export var explosion_scene : PackedScene
@export var critical_hit_chance : float = 0.1


var default_despawn_time = 1.3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var strength = broadside.shot_strength * randf_range(1-shot_strength_variance, 1+shot_strength_variance)
		
	if ship.is_in_group("player"):
		var direction = broadside.global_transform.y
		$Area2D.set_collision_layer_value(2, 1)
		$Area2D.set_collision_mask_value(3, 1) 
		apply_impulse( direction * strength + ship.velocity)

		
	else:
		var direction = broadside.global_transform.x
		$Area2D.set_collision_layer_value(3, true)
		$Area2D.set_collision_mask_value(1, true) 
		apply_impulse( direction * strength + ship.linear_velocity)

		
	despawn_timer.wait_time = randf_range(default_despawn_time - despawn_time_variance, default_despawn_time + despawn_time_variance)
	despawn_timer.start()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	
	var splash = splash_scene.instantiate()
	splash.global_position = global_position
	get_tree().current_scene.add_child(splash)
	splash.get_node("DropletParticles").emitting = true

	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	body.get_node("Health").take_damage(10, linear_velocity.normalized())
	
	var dmg_fx = damage_fx_scene.instantiate()
	dmg_fx.global_position = global_position
	get_tree().current_scene.add_child(dmg_fx)
	var particles = dmg_fx.get_node("GPUParticles2D")
	particles.rotation = linear_velocity.angle()
	particles.restart()
	particles.emitting = true
	
	if randf() < critical_hit_chance:
		print("EXPLOSION")
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		get_tree().current_scene.add_child(explosion)
		for explosion_particle_fx in explosion.get_children().filter(func(child): return child.is_in_group("explosion_particles")):
			explosion_particle_fx.restart()
	
	queue_free()
