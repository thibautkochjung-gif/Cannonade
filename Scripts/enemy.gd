extends RigidBody2D

enum BehaviorState {SEEK, ATTACK, EVADE, DEAD}
enum MastState {FULL_MAST, HALF_MAST, STOP, REVERSE}

var current_behavior_state: BehaviorState = BehaviorState.SEEK
var broadside_in_use: Node2D
var mast_state: MastState
var player: CharacterBody2D
var angle_to_player: float
var distance_to_player: float
var target = Vector2.ZERO
var angle_to_target: float
var distance_to_target: float
var current_avoidance_direction: float = 0.0  # -1 = left, 1 = right, 0 = none
var max_velocity: float

signal died

var SPEED_MAP = {
	MastState.FULL_MAST: 100.0,
	MastState.HALF_MAST: 50.0,
	MastState.STOP: 0.0,
	MastState.REVERSE: -20.0,
}

@export_group("Steering")
@export var angle_threshold: float = PI/4
@export var distance_threshold: float = 250
@export var turning_speed: float = 100
@export var acceleration_force: float = 400
@export var linear_damp_value: float = 0.745

@export_group("Combat")
@export var attack_range: float = 500
@export var accuracy: float = 0.1
@export var opportunistic_fire_window: float = 0.3
@export var opportunistic_fire_urgency_ceiling: float = 0.5
@export var sail_condition : SailCondition


@export_group("Avoidance")
@export var avoidance_ray_length: float = 200.0
@export var avoidance_ray_spread_degrees: float = 35.0
@export var avoidance_strength: float = 1.5
@export var avoidance_normal_threshold: float = 0.3
@export var force_reduction_amount: float = 0.7

@onready var status_effects : StatusEffects = $StatusEffects

func _ready() -> void:
	change_behavior_state(BehaviorState.SEEK)
	player = get_tree().get_first_node_in_group("player")
	var top_speed_force = SPEED_MAP[MastState.FULL_MAST] * acceleration_force
	max_velocity = top_speed_force / (mass * linear_damp_value)

	var spread_rad = deg_to_rad(avoidance_ray_spread_degrees)
	$AvoidanceRaycasts/AvoidanceRayCenter.target_position = Vector2(avoidance_ray_length, 0)
	$AvoidanceRaycasts/AvoidanceRayLeft.target_position = Vector2(cos(-spread_rad), sin(-spread_rad)) * avoidance_ray_length
	$AvoidanceRaycasts/AvoidanceRayRight.target_position = Vector2(cos(spread_rad), sin(spread_rad)) * avoidance_ray_length


func change_behavior_state(new_state: BehaviorState) -> void:
	current_behavior_state = new_state


func tick_seek(delta: float) -> Dictionary:
	mast_state = get_mast_state()
	var speed = SPEED_MAP[mast_state]

	target = _get_target_position(player.position, player.velocity)
	return {"speed": speed, "torque": angle_to_target*turning_speed*mass, "bypass_suppression": false}


func tick_attack(delta: float) -> Dictionary:
	mast_state = get_mast_state()
	var speed = SPEED_MAP[mast_state]
	var broadside_direction = transform.y if broadside_in_use == $RightBroadside else -transform.y
	var angle_from_broadside_to_player = broadside_direction.angle_to(player.global_position - global_position)
	var torque = 0.0
	var bypass_suppression = false

	target = _get_target_position(player.position, player.velocity)
	if abs(angle_from_broadside_to_player) > accuracy:
		torque = angle_from_broadside_to_player*turning_speed*mass
		bypass_suppression = abs(angle_from_broadside_to_player) < opportunistic_fire_window
	else:
		broadside_in_use.fire()
	return {"speed": speed, "torque": torque, "bypass_suppression": bypass_suppression}


func tick_evade(delta: float) -> Dictionary:
	# If the enemy is behind the player, they should rotate to player.transform.y
	# If the enemy is in front of the player, they should rotate to -player.transform.y
	var player_to_enemy = global_position - player.global_position
	var dot = player_to_enemy.dot(-player.transform.y)

	var evade_direction = player.transform.y if dot < 0 else -player.transform.y
	var angle_to_evade = transform.x.angle_to(evade_direction)

	return {"speed": SPEED_MAP[MastState.FULL_MAST], "torque": angle_to_evade * turning_speed * mass, "bypass_suppression": false}


func tick_dead(delta: float) -> Dictionary:
	return {"speed": 0.0, "torque": 0.0, "bypass_suppression": false}
	# death logic goes here later


func get_mast_state() -> MastState:
	# Mast state is: full if aligned and at great distance, half if one is untrue, stop if both are untrue
	if distance_to_target > distance_threshold:
		if abs(angle_to_target) > angle_threshold:
			return MastState.HALF_MAST
		else:
			return MastState.FULL_MAST
	else:
		if abs(angle_to_player) > angle_threshold:
			return MastState.STOP
		else:
			return MastState.HALF_MAST


func _get_target_position(player_position: Vector2, player_velocity: Vector2) -> Vector2:
	if linear_velocity.length() == 0 or player_velocity.length() < 5:
		return player_position
	var time_to_intercept = distance_to_player / linear_velocity.length()
	var intercept = player_position + player_velocity * time_to_intercept
	return intercept


func decide_behavior() -> void:
	var should_attack: bool
	var should_seek: bool
	var enough_cannons_are_ready: bool
	var broadside_in_use_is_aligned_to_target: bool

	enough_cannons_are_ready = broadside_in_use.cannon_ready_count > broadside_in_use.cannon_count * 0.7

	if (angle_to_target > 0 and broadside_in_use == $LeftBroadside) or (angle_to_target < 0 and broadside_in_use == $RightBroadside):
		broadside_in_use_is_aligned_to_target = false
	else:
		broadside_in_use_is_aligned_to_target = true

	if enough_cannons_are_ready:
		if distance_to_player < attack_range:
			should_attack = true
		else:
			should_seek = true

	if should_attack and current_behavior_state != BehaviorState.ATTACK:
		change_behavior_state(BehaviorState.ATTACK)

	if should_seek and current_behavior_state != BehaviorState.SEEK:
		change_behavior_state(BehaviorState.SEEK)

	if !enough_cannons_are_ready and current_behavior_state != BehaviorState.EVADE:
		if broadside_in_use_is_aligned_to_target:
			change_behavior_state(BehaviorState.EVADE)


func _physics_process(delta: float) -> void:
	if status_effects.is_stunned():
		return
		
	angle_to_target = transform.x.angle_to(target-global_position)
	distance_to_target = (target-global_position).length()
	angle_to_player = transform.x.angle_to(player.position-global_position)
	distance_to_player = (player.position - global_position).length()
	var behavior_result: Dictionary

	if angle_to_player > 0:
		broadside_in_use = $RightBroadside
	else:
		broadside_in_use = $LeftBroadside

	match current_behavior_state:
		BehaviorState.SEEK:
			behavior_result = tick_seek(delta)
		BehaviorState.ATTACK:
			behavior_result = tick_attack(delta)
		BehaviorState.EVADE:
			behavior_result = tick_evade(delta)
		BehaviorState.DEAD:
			behavior_result = tick_dead(delta)

	var avoidance_result = get_avoidance_torque(delta)
	var urgency = avoidance_result["urgency"]
	var allow_bypass = behavior_result["bypass_suppression"] and urgency < opportunistic_fire_urgency_ceiling

	var blended_torque: float
	if allow_bypass:
		blended_torque = behavior_result["torque"]
	else:
		blended_torque = behavior_result["torque"] * (1.0 - urgency) + avoidance_result["torque"]

	var blended_speed = behavior_result["speed"] * (1.0 - urgency * force_reduction_amount)

	apply_force(transform.x * blended_speed * acceleration_force * sail_condition.get_condition_ratio())
	apply_torque(blended_torque)

	for wake in $Wakes.get_children().filter(func(child): return child.is_in_group("wake")):
		wake.update_speed(linear_velocity.length() / max_velocity)


func _on_health_health_depleted() -> void:
	remove_from_group("enemy")
	died.emit()

	queue_free()


func _on_health_health_changed(_damage: float, max_health: float, current_health: float, _hit_direction: Vector2, _source: String, _fx_trigger_chance: float) -> void:
	$DamageDecals.update_health_ratio(current_health / max_health)


func _on_behavior_decision_timer_timeout() -> void:
	decide_behavior()


func get_avoidance_torque(delta: float) -> Dictionary:
	var ray_data = _gather_ray_data()
	var raw_direction = _compute_raw_steer_direction(ray_data)
	var direction = _apply_direction_bias(raw_direction)

	if direction == 0.0:
		return {"torque": 0.0, "urgency": 0.0}

	return _compute_urgency_and_torque(direction, ray_data)


func _gather_ray_data() -> Dictionary:
	var ray_data = {
		"center": null,
		"left": null,
		"right": null,
	}

	for ray_name in ray_data.keys():
		var ray = get_node("AvoidanceRaycasts/AvoidanceRay" + ray_name.capitalize())
		if ray.is_colliding():
			ray_data[ray_name] = {
				"distance": global_position.distance_to(ray.get_collision_point()),
				"normal": ray.get_collision_normal(),
			}

	return ray_data


func _compute_raw_steer_direction(ray_data: Dictionary) -> float:
	if ray_data["center"] != null:
		# Direct/urgent case - center is hit, need a real direction decision
		if ray_data["left"] == null:
			return -1.0
		elif ray_data["right"] == null:
			return 1.0
		else:
			var sideways = ray_data["center"]["normal"].dot(transform.y)
			if sideways > avoidance_normal_threshold:
				return 1.0
			elif sideways < -avoidance_normal_threshold:
				return -1.0
			else:
				var left_dist = ray_data["left"]["distance"]
				var right_dist = ray_data["right"]["distance"]
				return -1.0 if left_dist > right_dist else 1.0
	elif ray_data["left"] != null:
		# Peripheral scrape on the left only - nudge right, away from it
		return 1.0
	elif ray_data["right"] != null:
		# Peripheral scrape on the right only - nudge left, away from it
		return -1.0

	return 0.0


func _apply_direction_bias(raw_direction: float) -> float:
	# Persistent bias: once committed to a direction, keep it until fully clear of obstacles
	if raw_direction == 0.0:
		current_avoidance_direction = 0.0
		return 0.0

	if current_avoidance_direction == 0.0:
		current_avoidance_direction = raw_direction

	return current_avoidance_direction


func _compute_urgency_and_torque(direction: float, ray_data: Dictionary) -> Dictionary:
	var closest_hit_distance = avoidance_ray_length
	for ray_name in ray_data.keys():
		if ray_data[ray_name] != null:
			closest_hit_distance = min(closest_hit_distance, ray_data[ray_name]["distance"])

	var urgency = clamp(1.0 - (closest_hit_distance / avoidance_ray_length), 0.0, 1.0)
	urgency = sqrt(urgency)
	var torque = direction * urgency * turning_speed * mass * avoidance_strength

	return {"torque": torque, "urgency": urgency}
	

func zero_velocity() -> void:
	linear_velocity = Vector2.ZERO
