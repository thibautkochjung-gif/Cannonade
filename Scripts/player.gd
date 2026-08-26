extends CharacterBody2D

@export var max_speed = 100
@export var acceleration_factor = 0.1
@export var angular_acceleration_factor = 0.005
@export var max_angular_speed = 0.5
@export var sail_condition : SailCondition

@onready var health: Health = $Health
@onready var left_broadside: Node = $LeftBroadside
@onready var right_broadside: Node = $RightBroadside
@onready var status_effects: StatusEffects = $StatusEffects
@onready var ammo_manager: AmmoManager = $AmmoManager

signal mast_state_changed(new_state: MastState)
enum MastState {FULL_MAST, HALF_MAST, STOP, REVERSE}

var SPEED_MAP = {
	MastState.FULL_MAST: 1.0,
	MastState.HALF_MAST: 0.5,
	MastState.STOP: 0.0,
	MastState.REVERSE: -0.2,
}

var ANGULAR_SPEED_MAP = {
	MastState.FULL_MAST: 0.4,
	MastState.HALF_MAST: 1.0,
	MastState.STOP: 0.2,
	MastState.REVERSE: 0.6,
}

var current_mast_state = MastState.STOP
var current_speed = SPEED_MAP[current_mast_state] * max_speed
var current_angular_speed = ANGULAR_SPEED_MAP[current_mast_state] * max_angular_speed
var is_aiming := false
var active_broadside: Node2D = null

var loadout_speed_multiplier: float = 1.0
var loadout_angular_multiplier: float = 1.0

func _ready() -> void:
	$LeftBroadside.fired.connect(_on_broadside_fired)
	$RightBroadside.fired.connect(_on_broadside_fired)
	loadout_speed_multiplier = RunState.get_aggregate_multiplier("speed_multiplier")
	loadout_angular_multiplier = RunState.get_aggregate_multiplier("steering_multiplier")
	GameManagerScene.on_player_ready(self)

func _unhandled_input(event: InputEvent) -> void:
	
	if status_effects.is_stunned():
		return
	
	if event.is_action_pressed("speed_up"):
		current_mast_state = clampi(current_mast_state - 1, MastState.FULL_MAST, MastState.REVERSE) as MastState
	elif event.is_action_pressed("slow_down"):
		current_mast_state = clampi(current_mast_state + 1, MastState.FULL_MAST, MastState.REVERSE) as MastState
	
	mast_state_changed.emit(current_mast_state)
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_aiming = true
			active_broadside = _broadside_for_mouse(event.position)
			active_broadside.show_aim()
		else:
			is_aiming = false
			if active_broadside:
				active_broadside.fire()
				active_broadside = null
	
	if event.is_action_pressed("ammo_1"):
		ammo_manager.select_ammo(1)
	elif event.is_action_pressed("ammo_2"):
		ammo_manager.select_ammo(2)
	elif event.is_action_pressed("ammo_3"):
		ammo_manager.select_ammo(3)
	elif event.is_action_pressed("ammo_4"):
		ammo_manager.select_ammo(4)


func _broadside_for_mouse(screen_position: Vector2) -> Node2D:
	var mouse_world_position = get_viewport().canvas_transform.affine_inverse() * screen_position
	var vector_to_mouse = mouse_world_position - position
	var vector_right_side = transform.x.orthogonal()
	if vector_to_mouse.dot(vector_right_side) > 0:
		return $LeftBroadside
	else:
		return $RightBroadside


func _physics_process(delta: float) -> void:
	
	if status_effects.is_stunned():
		if is_aiming:
			is_aiming = false
			if active_broadside:
				active_broadside.hide_aim()
				active_broadside = null
		move_and_slide()
		return
	
	var target_speed = SPEED_MAP[current_mast_state] * max_speed * sail_condition.get_speed_multiplier() * loadout_speed_multiplier
	current_speed = lerp(current_speed, target_speed, acceleration_factor)
	var target_angular_speed = ANGULAR_SPEED_MAP[current_mast_state] * max_angular_speed * sail_condition.get_turn_multiplier() * loadout_angular_multiplier
	current_angular_speed = lerp(current_angular_speed, target_angular_speed, angular_acceleration_factor)
	
	if Input.is_action_pressed("steer_right"):
		rotation += current_angular_speed * delta
	if Input.is_action_pressed("steer_left"):
		rotation -= current_angular_speed * delta
		
	velocity = Vector2.RIGHT.rotated(rotation) * current_speed
	move_and_slide()
	
	for wake in $Wakes.get_children().filter(func(child): return child.is_in_group("wake")):
		wake.update_speed(current_speed / max_speed)


func _on_broadside_fired(amount, direction) -> void:
	Fx.recoil(amount, direction)


func _on_health_health_depleted() -> void:
	GameManagerScene.player_death()


func _on_health_health_changed(damage: float, max_health: float, current_health: float, hit_direction: Vector2, source: String, _fx_trigger_chance: float) -> void:
	
	var damage_to_max_health_ratio: float = damage / max_health
	if damage_to_max_health_ratio > 0.0:
		Fx.shake(shake_strength_from(damage_to_max_health_ratio, source), hit_direction)
		
	$DamageDecals.update_health_ratio(current_health / max_health)


func zero_velocity() -> void:
	current_speed = 0.0
	velocity = Vector2.ZERO


func shake_strength_from(damage: float, source: String) -> float:
	var base = clamp(damage / $Health.max_health, 0.1, 1.0)
	return base * 10.0 if source == "collision" else base
