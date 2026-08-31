extends Node

signal wind_updated(direction: Vector2, speed: float)

@export_group("Change timing")
@export var min_change_interval: float = 15.0
@export var max_change_interval: float = 35.0

@export var transition_duration: float = 8.0

@export_group("Wind speed range")
@export var min_wind_speed: float = 0.0
@export var max_wind_speed: float = 60.0

@export_group("Direction curves")
## X = angle between ship heading and wind direction, normalized 0..1
## (0 = wind directly behind, 1 = wind directly ahead).
## Y = multiplier applied to the ship's forward speed.
@export var speed_by_angle_curve: Curve
## Same X axis. Y = multiplier applied to the ship's turn rate.
@export var turn_by_angle_curve: Curve

@export_group("Wind strength curve")
## X = current wind speed normalized to max_wind_speed (0..1).
## Y = how strongly the two curves above apply (0 = ignore direction
## entirely, 1 = apply it fully). Deliberately not linear - see the
## curve-creation notes for why.
@export var strength_by_wind_speed_curve: Curve

# --- Public state ---------------------------------------------------------

## Angle (radians) of the direction the wind is blowing TOWARD.
var current_angle: float = 0.0
var current_speed: float = 20.0

# --- Internal transition state --------------------------------------------

var _start_angle: float = 0.0
var _start_speed: float = 20.0
var _objective_angle: float = 0.0
var _objective_speed: float = 20.0
var _transition_t: float = 1.0  # 1.0 = transition finished

@onready var _change_timer: Timer = Timer.new()


func _ready() -> void:
	if speed_by_angle_curve == null:
		speed_by_angle_curve = _build_default_curve([
			[0.00, 0.85], [0.25, 1.00], [0.50, 0.85], [0.75, 0.55], [1.00, 0.20],
		])
	if turn_by_angle_curve == null:
		turn_by_angle_curve = _build_default_curve([
			[0.00, 0.45], [0.25, 0.80], [0.50, 1.00], [0.75, 0.75], [1.00, 0.30],
		])
	if strength_by_wind_speed_curve == null:
		strength_by_wind_speed_curve = _build_default_curve([
			[0.00, 0.00], [0.40, 0.15], [1.00, 1.00],
		])

	_start_angle = current_angle
	_start_speed = current_speed
	_objective_angle = current_angle
	_objective_speed = current_speed

	add_child(_change_timer)
	_change_timer.one_shot = true
	_change_timer.timeout.connect(_on_change_timer_timeout)
	_change_timer.start(randf_range(min_change_interval, max_change_interval))


func _process(delta: float) -> void:
	if _transition_t >= 1.0:
		return
	_transition_t = min(_transition_t + delta / transition_duration, 1.0)
	current_angle = lerp_angle(_start_angle, _objective_angle, _transition_t)
	current_speed = lerp(_start_speed, _objective_speed, _transition_t)
	wind_updated.emit(current_direction(), current_speed)


func _on_change_timer_timeout() -> void:
	_start_angle = current_angle
	_start_speed = current_speed
	_objective_angle = randf_range(-PI, PI)
	_objective_speed = randf_range(min_wind_speed, max_wind_speed)
	_transition_t = 0.0
	_change_timer.start(randf_range(min_change_interval, max_change_interval))


func _build_default_curve(points: Array) -> Curve:
	var curve := Curve.new()
	for p in points:
		curve.add_point(Vector2(p[0], p[1]))
	return curve


## Unit vector the wind is blowing toward.
func current_direction() -> Vector2:
	return Vector2.RIGHT.rotated(current_angle)


# --- Ship-facing API -------------------------------------------------------

## 0..1 position along the direction curves' X axis for this ship:
## 0 = wind directly coming from behind, 1 = wind directly coming from ahead.
func _angle_t(ship_forward: Vector2) -> float:
	return abs(ship_forward.angle_to(current_direction())) / PI


## Degrees (0..180) between the ship's forward vector and the direction
## the wind is blowing toward. Not used internally - handy for a debug
## HUD readout if you want one.
func angle_to_ship_deg(ship_forward: Vector2) -> float:
	return rad_to_deg(abs(ship_forward.angle_to(current_direction())))


func _wind_strength() -> float:
	var normalized_speed: float = clamp(current_speed / max_wind_speed, 0.0, 1.0)
	return strength_by_wind_speed_curve.sample(normalized_speed)


## Multiplier for a ship's forward speed. 1.0 = no effect (dead calm);
## approaches the direction curve's value as wind strength rises.
func get_speed_multiplier(ship_forward: Vector2) -> float:
	var directional_mult := speed_by_angle_curve.sample(_angle_t(ship_forward))
	return lerp(1.0, directional_mult, _wind_strength())


## Multiplier for a ship's turn rate / torque, same scaling as above.
func get_turn_multiplier(ship_forward: Vector2) -> float:
	var directional_mult := turn_by_angle_curve.sample(_angle_t(ship_forward))
	return lerp(1.0, directional_mult, _wind_strength())
