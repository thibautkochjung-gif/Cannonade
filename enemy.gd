extends RigidBody2D

enum BehaviorState {SEEKING, ATTACK, EVADE, DEAD}
var current_state: BehaviorState = BehaviorState.SEEKING

var broadside_in_use : Node2D
var mast_state: MastState

var player : CharacterBody2D
var target = Vector2.ZERO
var angle_to_target: float
var distance_to_target: float

@export var max_speed: float = 400
@export var angle_threshold: float = PI/4
@export var distance_threshold: float = 400
@export var turning_speed: float = 50
@export var range: float = 500
@export var accuracy: float = 0.1

enum MastState {FULL_MAST, HALF_MAST, STOP, REVERSE}

var SPEED_MAP = {
	MastState.FULL_MAST: 100.0,
	MastState.HALF_MAST: 50.0,
	MastState.STOP: 0.0,
	MastState.REVERSE: -20.0,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_behavior_state(BehaviorState.SEEKING)
	player = get_tree().get_first_node_in_group("player")

func change_behavior_state(new_state: BehaviorState) -> void:
	current_state = new_state
	match new_state:
		BehaviorState.SEEKING:
			print("Entered SEEKING")
		BehaviorState.ATTACK:
			print("Entered ATTACK")
		BehaviorState.EVADE:
			print("Entered ATTACK")
		BehaviorState.DEAD:
			print("Entered DEAD")
			
func tick_seeking(delta: float) -> void:
	mast_state = get_mast_state()
	var speed = SPEED_MAP[mast_state]
	
	target = _get_target_position(player.position, player.velocity)
	apply_force(transform.x*speed*max_speed)
	apply_torque(angle_to_target*turning_speed*mass)

func tick_attack(delta: float) -> void:
	var mast_state = get_mast_state()
	var speed = SPEED_MAP[mast_state]
	var angle_to_player = transform.x.angle_to(player.position-global_position)
	
	target = _get_target_position(player.position, player.velocity)
	apply_force(transform.x*speed*max_speed)
	if abs(angle_to_player) < PI/2 - accuracy or abs(angle_to_player) < PI/2 + accuracy:
		apply_torque(-angle_to_player*turning_speed*mass)
	else:
		broadside_in_use.fire()

	# broadside logic goes here later

func tick_evade(delta: float) -> void:
	pass
	# death logic goes here later

func tick_dead(delta: float) -> void:
	pass
	# death logic goes here later

func get_mast_state() -> MastState:
	#Mast state is : full if aligned and at great distance, half if one is untrue, stop if both are untrue
	
	var angle_to_target = transform.x.angle_to(target - global_position)
	var distance_to_target = global_position.distance_to(target)
	
	if distance_to_target > distance_threshold:
		if abs(angle_to_target) > angle_threshold:
			return MastState.HALF_MAST  
		else:
			return MastState.FULL_MAST
	else:
		if abs(angle_to_target) > angle_threshold:
			return MastState.STOP
		else:
			return MastState.HALF_MAST

func _get_target_position(player_position, player_velocity) -> Vector2:
	if linear_velocity.length() == 0 or player_velocity.length() < 5:
		return player_position
	var distance_to_player = (player_position - global_position).length()
	var time_to_intercept = distance_to_player / linear_velocity.length()
	var intercept = player_position + player_velocity * time_to_intercept
	return intercept

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	angle_to_target = transform.x.angle_to(target-global_position)
	distance_to_target = (target-global_position).length()
	var should_attack: bool
	
	if angle_to_target > 0:
		broadside_in_use = $RightBroadside
	else:
		broadside_in_use = $LeftBroadside
	
	if distance_to_target < range and broadside_in_use.cannon_ready_count > broadside_in_use.cannon_count * 0.7 :
		should_attack = true
		
	if should_attack:
		change_behavior_state(BehaviorState.ATTACK)
	
	match current_state:
		BehaviorState.SEEKING:
			tick_seeking(delta)
		BehaviorState.ATTACK:
			tick_attack(delta)
		BehaviorState.EVADE:
			tick_evade(delta)
		BehaviorState.DEAD:
			tick_dead(delta)


	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_1"):
		change_behavior_state(BehaviorState.SEEKING)
	if event.is_action_pressed("ui_2"):
		change_behavior_state(BehaviorState.ATTACK)
	if event.is_action_pressed("ui_3"):
		change_behavior_state(BehaviorState.DEAD)
	
func _on_health_health_depleted() -> void:
	queue_free()
