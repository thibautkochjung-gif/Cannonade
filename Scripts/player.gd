extends CharacterBody2D

@export var max_speed = 100
@export var acceleration_factor = 0.1
@export var angular_acceleration_factor = 0.005
@export var angular_decay_factor: float = 0.02
@export var max_angular_speed = 0.5
@export var sail_condition : SailCondition

@export_group("Wind response")
## How fast the ship's felt wind effect on speed catches up to wind's
## actual current multiplier, independent of the ship's own acceleration
## above. Higher = wind is felt almost immediately on speed; lower =
## wind takes longer to "take hold." Turning doesn't need an equivalent
## knob - see the signed current_angular_speed model below.
@export var wind_speed_catchup_factor: float = 0.05

@export_group("Currents")
@export var current_catchup_factor: float = 0.03  # same role as wind_speed_catchup_factor


@onready var health: Health = $Health
@onready var left_broadside: Node = $LeftBroadside
@onready var right_broadside: Node = $RightBroadside
@onready var status_effects: StatusEffects = $StatusEffects
@onready var ammo_manager: AmmoManager = $AmmoManager
@onready var current_detector: CurrentDetector = $CurrentDetector

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
var current_angular_speed: float = 0.0  # signed: positive = turning right, negative = turning left
var current_wind_speed_multiplier: float = 1.0
var is_aiming := false
var active_broadside: Node2D = null

var loadout_speed_multiplier: float = 1.0
var loadout_angular_multiplier: float = 1.0
var boost_multiplier: float = 1.0
var debug_speed_multiplier: float = 1.0

var current_push: Vector2 = Vector2.ZERO

func _ready() -> void:
	$LeftBroadside.fired.connect(_on_broadside_fired)
	$RightBroadside.fired.connect(_on_broadside_fired)
	
	loadout_speed_multiplier = RunState.get_aggregate_multiplier("speed_multiplier")
	loadout_angular_multiplier = RunState.get_aggregate_multiplier("steering_multiplier")
	_instantiate_module_behaviors()
	
	GameManagerScene.on_player_ready(self)

func _instantiate_module_behaviors() -> void:
	for slot_type in ModuleData.SlotType.values():
		var equipped: Array = RunState.get_equipped_modules(slot_type)
		for slot_index in equipped.size():
			var module: ModuleData = equipped[slot_index]
			if module == null or module.component_scene == null:
				continue
			if slot_type == ModuleData.SlotType.DECK:
				_instantiate_cannon_row(module, slot_index)
			else:
				add_child(module.component_scene.instantiate())

	$LeftBroadside.rebuild_cannons()
	$RightBroadside.rebuild_cannons()


func _instantiate_cannon_row(module: ModuleData, slot_index: int) -> void:
	var side: ShipLoadoutLayout.DeckSide = RunState.get_deck_side_for_slot(slot_index)
	var broadside: Node2D = $LeftBroadside if side == ShipLoadoutLayout.DeckSide.LEFT else $RightBroadside

	var area := broadside.get_node("RowArea")
	var row := module.component_scene.instantiate()
	if row is CannonRow:
		row.cannon_scene = module.cannon_scene
		row.cannon_count = module.cannon_count
		row.start_point = area.get_node("Start").position
		row.end_point = area.get_node("End").position
	area.add_child(row)


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
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_cancel_shot()
	
	if event.is_action_pressed("ammo_1"):
		ammo_manager.select_ammo(1)
	elif event.is_action_pressed("ammo_2"):
		ammo_manager.select_ammo(2)
	elif event.is_action_pressed("ammo_3"):
		ammo_manager.select_ammo(3)
	elif event.is_action_pressed("ammo_4"):
		ammo_manager.select_ammo(4)


func _cancel_shot() -> void:
	if not active_broadside:
		return
	is_aiming = false
	active_broadside.hide_aim()
	active_broadside = null


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
	
	# Speed: wind's contribution catches up on its own schedule
	# (wind_speed_catchup_factor), decoupled from the ship's own heavy
	# acceleration_factor below.
	var target_wind_speed_multiplier: float = Wind.get_speed_multiplier(transform.x)
	current_wind_speed_multiplier = lerp(current_wind_speed_multiplier, target_wind_speed_multiplier, wind_speed_catchup_factor)
	
	var target_speed = SPEED_MAP[current_mast_state] * max_speed * sail_condition.get_speed_multiplier() * loadout_speed_multiplier * boost_multiplier * debug_speed_multiplier
	current_speed = lerp(current_speed, target_speed, acceleration_factor)
	print("speed: ", current_speed, " (effective: ", current_speed * current_wind_speed_multiplier, ")")
	
	var target_angular_speed_magnitude : float = ANGULAR_SPEED_MAP[current_mast_state] * max_angular_speed * sail_condition.get_turn_multiplier() * Wind.get_turn_multiplier(transform.x) * loadout_angular_multiplier
	
	var turning_right := Input.is_action_pressed("steer_right")
	var turning_left := Input.is_action_pressed("steer_left")
	var input_direction := (1.0 if turning_right else 0.0) - (1.0 if turning_left else 0.0)
	
	if input_direction != 0.0:
		current_angular_speed = lerp(current_angular_speed, target_angular_speed_magnitude * input_direction, angular_acceleration_factor)
	else:
		current_angular_speed = lerp(current_angular_speed, 0.0, angular_decay_factor)
	
	rotation += current_angular_speed * delta
	print("angular speed: ", current_angular_speed)
	
	var target_current_push: Vector2 = current_detector.get_total_push(global_position, transform.x)
	current_push = current_push.lerp(target_current_push, current_catchup_factor)
	
	velocity = Vector2.RIGHT.rotated(rotation) * current_speed * current_wind_speed_multiplier + current_push
	move_and_slide()
	
	for wake in $Wakes.get_children().filter(func(child): return child.is_in_group("wake")):
		wake.update_speed((current_speed * current_wind_speed_multiplier) / max_speed)


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
