extends Node2D

@export var ship : Node2D
@export var broadside : Node2D
@export var despawn_timer : Timer
@export var splash_scene : PackedScene
@export var damage_fx_scene : PackedScene
@export var explosion_scene : PackedScene
@export var ammo_data : AmmoData
@export var base_cannonball_scale : Vector2 = Vector2(0.03,0.03)

var direction: Vector2
var velocity: Vector2
var effects_parent: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	effects_parent = GameManagerScene.world_root
	var velocity_multiplier = randf_range(
	1.0 - ammo_data.velocity_variance,
	1.0 + ammo_data.velocity_variance
	)	
	
	$BallSprite.configure(
		ammo_data.ball_texture, 
		ammo_data.ball_spin_speed_range, 
		base_cannonball_scale * ammo_data.projectile_scale * Vector2(1,1))
	
	var strength = broadside.shot_strength * velocity_multiplier

	
	if ship.is_in_group("player"):
		$Area2D.set_collision_layer_value(2, true) 
		$Area2D.set_collision_mask_value(3, true) #enemy layer
		$Area2D.set_collision_mask_value(6, true) #terrain layer

		velocity = direction * strength + ship.velocity

		
	else:
		$Area2D.set_collision_layer_value(4, true)
		$Area2D.set_collision_mask_value(1, true) #player layer
		$Area2D.set_collision_mask_value(3, true) #enemy layer
		$Area2D.set_collision_mask_value(6, true) #terrain layer

		velocity = direction * strength + ship.linear_velocity
	
	despawn_timer.wait_time = randf_range(
		ammo_data.max_flight_time - ammo_data.max_flight_time_variance,
		ammo_data.max_flight_time + ammo_data.max_flight_time_variance)
	despawn_timer.wait_time *= sqrt(velocity_multiplier)
	despawn_timer.start()
	

func _physics_process(delta: float) -> void:
	velocity = velocity.lerp(Vector2.ZERO, ammo_data.drag * delta)
	global_position += velocity * delta


func _on_timer_timeout() -> void:
	
	if TerrainQuery.is_over_land(global_position) == false:
		if randf() <= ammo_data.splash_chance:
			var splash = splash_scene.instantiate()
			splash.global_position = global_position
			if is_instance_valid(effects_parent):
				effects_parent.add_child(splash)
				splash.setup(
					ammo_data.water_splash_size,
					ammo_data.water_splash_particle_scale,
					ammo_data.water_splash_particle_multiplier
				)
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == ship:
		return
	
	if body.is_in_group("terrain"):
		queue_free()
		return
	
	if ammo_data.hull_damage > 0:
		var hull_damage = ammo_data.hull_damage * RunState.get_multiplier_for(body, "damage_taken_multiplier")
		body.get_node("Health").take_damage(
			hull_damage,
			velocity.normalized(),
			"cannon",
			ammo_data.damage_fx_trigger_chance
		)
		
	if ammo_data.sail_damage > 0:
		body.get_node("SailCondition").take_damage(
			ammo_data.sail_damage,
		)
	
	if ammo_data.stun_trauma > 0:
		body.get_node("StatusEffects").apply_stun(
			ammo_data.stun_trauma,
		)
		
	if ammo_data.burn_amount > 0:
		body.get_node("StatusEffects").apply_burn(
			ammo_data.burn_amount,
			global_position,
		)
	
	
	if randf() < ammo_data.explosion_chance:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		if is_instance_valid(effects_parent):
			explosion.global_position = global_position
			effects_parent.add_child(explosion)
	
	queue_free()
