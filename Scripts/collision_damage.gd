extends Node
class_name CollisionDamage

@export var ship: Node2D

@export var front_damage := 1.0
@export var side_back_damage := 4.0

@export var speed_damage_multiplier := 0.01
@export var front_angle_threshold := PI / 3


func on_ship_collision(other_ship: Node2D) -> void:
	var impact_direction = get_impact_direction(other_ship)
	var hit_angle = get_hit_angle(other_ship, ship)

	var base_damage = get_base_damage(hit_angle)
	var speed_multiplier = get_speed_multiplier(other_ship)

	var final_damage = base_damage * speed_multiplier

	print(
		ship.name,
		" rammed ",
		other_ship.name,
		" for ",
		final_damage,
		" damage"
	)

	other_ship.get_node("Health").take_damage(final_damage, impact_direction, "collision")


func get_impact_direction(other_ship: Node2D) -> Vector2:
	return (
		other_ship.global_position - ship.global_position
	).normalized()


func get_hit_angle(target: Node2D, attacker: Node2D) -> float:
	var direction_to_attacker = (
		attacker.global_position - target.global_position
	).normalized()

	var target_forward = target.transform.x

	return abs(target_forward.angle_to(direction_to_attacker))


func get_base_damage(angle: float) -> float:
	if angle < front_angle_threshold:
		return front_damage
	else:
		return side_back_damage


func get_speed_multiplier(other_ship: Node2D) -> float:
	var relative_speed = get_relative_speed(other_ship)

	return 1.0 + relative_speed * relative_speed * speed_damage_multiplier 


func get_relative_speed(other_ship: Node2D) -> float:
	var my_velocity = get_ship_velocity(ship)
	var other_velocity = get_ship_velocity(other_ship)

	return (my_velocity - other_velocity).length()


func get_ship_velocity(body: Node2D) -> Vector2:
	if body is CharacterBody2D:
		return body.velocity

	if body is RigidBody2D:
		return body.linear_velocity

	return Vector2.ZERO
