extends Node2D

@export var cannonball_scene : PackedScene
@export var cooldown_time_avg = 8.0
@export var cooldown_time_variance = 2

var ship : Node2D
var ready_to_fire = true
var ammo_manager: AmmoManager

signal ready_to_fire_signal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ship = get_parent().get_parent()
	$CooldownTimer.wait_time = randf_range(cooldown_time_avg - cooldown_time_variance, cooldown_time_avg + cooldown_time_variance)
	ammo_manager = ship.get_node("AmmoManager")


func cannon_fire(broadside_firing):
	
	if not ready_to_fire:
		return
	
	var ammo = ammo_manager.current_ammo

	
	for i in ammo.amount:
		var cannonball = cannonball_scene.instantiate()
		
		var direction: Vector2

		if ship.is_in_group("player"):
			direction = broadside_firing.global_transform.y
		else:
			direction = broadside_firing.global_transform.x

		var spread = deg_to_rad(
			randf_range(
				-ammo.spread_angle / 2.0,
				ammo.spread_angle / 2.0
			)
		)
		cannonball.direction = direction.rotated(spread)

		cannonball.global_position = global_position
		cannonball.ship = ship
		cannonball.broadside = broadside_firing
		cannonball.ammo_data = ammo_manager.current_ammo
		get_tree().root.add_child(cannonball)
	
	ready_to_fire = false
	$CooldownTimer.start()
	$MuzzleSmoke.restart()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cooldown_timer_timeout() -> void:
	ready_to_fire = true
	$CooldownTimer.wait_time = randf_range(cooldown_time_avg - cooldown_time_variance, cooldown_time_avg + cooldown_time_variance)
	ready_to_fire_signal.emit()
