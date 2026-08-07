extends RigidBody2D

enum BehaviorState {SEEK, ATTACK, EVADE, DEAD}
var current_behavior_state: BehaviorState = BehaviorState.SEEK

var broadside_in_use : Node2D
var mast_state: MastState

var player : CharacterBody2D
var angle_to_player: float
var distance_to_player: float
var target = Vector2.ZERO
var angle_to_target: float
var distance_to_target: float

@export var acceleration_force: float = 400
@export var angle_threshold: float = PI/4
@export var distance_threshold: float = 250
@export var turning_speed: float = 100
@export var attack_range: float = 500
@export var accuracy: float = 0.1
@export var linear_damp_value: float = 0.745


enum MastState {FULL_MAST, HALF_MAST, STOP, REVERSE}

var max_velocity: float

var SPEED_MAP = {
	MastState.FULL_MAST: 100.0,
	MastState.HALF_MAST: 50.0,
	MastState.STOP: 0.0,
	MastState.REVERSE: -20.0,
}

func _ready() -> void:
	change_behavior_state(BehaviorState.SEEK)
	player = get_tree().get_first_node_in_group("player")
	var top_speed_force = SPEED_MAP[MastState.FULL_MAST] * acceleration_force
	max_velocity = top_speed_force / (mass * linear_damp_value)


func change_behavior_state(new_state: BehaviorState) -> void:
	current_behavior_state = new_state
	match new_state:
		BehaviorState.SEEK:
			print("Entered SEEK")
		BehaviorState.ATTACK:
			print("Entered ATTACK")
		BehaviorState.EVADE:
			print("Entered EVADE")
		BehaviorState.DEAD:
			print("Entered DEAD")
			
func tick_seek(delta: float) -> void:
	mast_state = get_mast_state()
	var speed = SPEED_MAP[mast_state]
	
	target = _get_target_position(player.position, player.velocity)
	apply_force(transform.x*speed*acceleration_force)
	apply_torque(angle_to_target*turning_speed*mass)

func tick_attack(delta: float) -> void:
	mast_state = get_mast_state()
	var speed = SPEED_MAP[mast_state]
	var broadside_direction = transform.y if broadside_in_use == $RightBroadside else -transform.y
	var angle_from_broadside_to_player = broadside_direction.angle_to(player.global_position - global_position)
	
	target = _get_target_position(player.position, player.velocity)
	apply_force(transform.x*speed*acceleration_force)
	if abs(angle_from_broadside_to_player) > accuracy:
		apply_torque(angle_from_broadside_to_player*turning_speed*mass)
	else:
		broadside_in_use.fire()
		print("Fire")

func tick_evade(delta: float) -> void:
	#If the enemy is behind the player, they should rotate to player.transform.y
	#If the enemy is in front of the player, they should rotate to -player.transform.y
	var player_to_enemy = global_position - player.global_position
	var dot = player_to_enemy.dot(-player.transform.y)
	
	var evade_direction = player.transform.y if dot < 0 else -player.transform.y
	var angle_to_evade = transform.x.angle_to(evade_direction)
	
	apply_torque(angle_to_evade * turning_speed * mass)
	apply_force(transform.x * SPEED_MAP[MastState.FULL_MAST] * acceleration_force)

func tick_dead(delta: float) -> void:
	pass
	# death logic goes here later

func get_mast_state() -> MastState:
	#Mast state is : full if aligned and at great distance, half if one is untrue, stop if both are untrue
	
	angle_to_target = transform.x.angle_to(target - global_position)
	distance_to_target = global_position.distance_to(target)
	
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

func _get_target_position(player_position: Vector2, player_velocity:Vector2) -> Vector2:
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
		
	if enough_cannons_are_ready :
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
	angle_to_target = transform.x.angle_to(target-global_position)
	distance_to_target = (target-global_position).length()
	angle_to_player = transform.x.angle_to(player.position-global_position)
	distance_to_player = (player.position - global_position).length()

	if angle_to_player > 0:
		broadside_in_use = $RightBroadside
	else:
		broadside_in_use = $LeftBroadside
	
	match current_behavior_state:
		BehaviorState.SEEK:
			tick_seek(delta)
		BehaviorState.ATTACK:
			tick_attack(delta)
		BehaviorState.EVADE:
			tick_evade(delta)
		BehaviorState.DEAD:
			tick_dead(delta)
			
	for wake in get_children().filter(func(child): return child.is_in_group("wake")):
		wake.update_speed(linear_velocity.length() / max_velocity)
		
func _on_health_health_depleted() -> void:
	queue_free()

func _on_behavior_decision_timer_timeout() -> void:
	decide_behavior()
