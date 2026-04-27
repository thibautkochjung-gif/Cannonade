extends CharacterBody2D

@export var max_speed = 100
@export var acceleration_factor = 0.1
@export var angular_speed = 1

enum MastState {FULL_MAST, HALF_MAST, STOP, REVERSE}

var SPEED_MAP = {
	MastState.FULL_MAST: 100.0,
	MastState.HALF_MAST: 50.0,
	MastState.STOP: 0.0,
	MastState.REVERSE: -20.0,
}

var current_mast_state = MastState.STOP
var current_speed = SPEED_MAP[current_mast_state]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("speed_up"):
		current_mast_state = (current_mast_state - 1) as MastState
	elif event.is_action_pressed("slow_down"):
		current_mast_state = (current_mast_state + 1) as MastState
	print(current_mast_state)


func _physics_process(delta: float) -> void:
	
	var target_speed = SPEED_MAP[current_mast_state]
	current_speed = lerp(current_speed, target_speed, acceleration_factor)

	
	if Input.is_action_pressed("steer_right"):
		rotation += angular_speed * delta
	if Input.is_action_pressed("steer_left"):
		rotation -= angular_speed * delta
		
	velocity = Vector2.UP.rotated(rotation) * current_speed
	move_and_slide()
	print(velocity)
