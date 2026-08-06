extends CharacterBody2D

@export var max_speed = 100
@export var acceleration_factor = 0.1
@export var angular_acceleration_factor = 0.005
@export var max_angular_speed = 0.5

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

func _ready() -> void:
	$LeftBroadside.fired.connect(_on_broadside_fired)
	$RightBroadside.fired.connect(_on_broadside_fired)

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("speed_up"):
		current_mast_state = clampi(current_mast_state - 1, MastState.FULL_MAST, MastState.REVERSE) as MastState
	elif event.is_action_pressed("slow_down"):
		current_mast_state = clampi(current_mast_state + 1, MastState.FULL_MAST, MastState.REVERSE) as MastState

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pass
		else:
			var mouse_world_position = get_viewport().canvas_transform.affine_inverse() * event.position
			var vector_to_mouse = mouse_world_position - position
			var vector_right_side = transform.y.orthogonal()
			if vector_to_mouse.dot(vector_right_side) > 0 :
				$RightBroadside.fire()
			else :
				$LeftBroadside.fire()


func _physics_process(delta: float) -> void:
	
	var target_speed = SPEED_MAP[current_mast_state] * max_speed
	current_speed = lerp(current_speed, target_speed, acceleration_factor)
	var target_angular_speed = ANGULAR_SPEED_MAP[current_mast_state] * max_angular_speed
	current_angular_speed = lerp(current_angular_speed, target_angular_speed, angular_acceleration_factor)
	
	if Input.is_action_pressed("steer_right"):
		rotation += current_angular_speed * delta
	if Input.is_action_pressed("steer_left"):
		rotation -= current_angular_speed * delta
		
	velocity = Vector2.UP.rotated(rotation) * current_speed
	move_and_slide()
	
	
func _on_broadside_fired(amount, direction) -> void:
	Fx.recoil(amount, direction)


func _on_health_health_depleted() -> void:
	GameManagerScene.player_death()


func _on_health_health_changed(damage_to_max_health_ratio: float, direction: Vector2) -> void:
	if damage_to_max_health_ratio > 0.0:
		Fx.shake(shake_strength_from(damage_to_max_health_ratio), direction)


func shake_strength_from(damage_to_max_health_ratio: float) -> float:
	return clamp(damage_to_max_health_ratio, 0.05, 1.0)
