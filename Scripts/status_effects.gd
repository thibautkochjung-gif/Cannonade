class_name StatusEffects
extends Node

@export var health : Health 

@export_group("Stun")
@export var stun_duration: float = 3.0
@export var max_stun_trauma: float = 100.0
@export var stun_trauma_decay: float = 20.0
@export var max_stun_chance: float = 0.5

@export_group("Burn")
@export var burn_tick_interval: float = 0.5
@export var burn_decay: float = 1.0



var stun_trauma: float = 0.0
var stun_time: float = 0.0

var burn: float = 0.0
var peak_burn: float = 0.0
var burn_tick_timer: float = 0.0

signal burn_applied(position: Vector2)
signal burn_changed(current: float, peak: float)
signal burn_stopped


func apply_stun(trauma: float) -> void:
	# Cannot accumulate trauma while already stunned.
	if is_stunned():
		return

	stun_trauma += trauma
	stun_trauma = min(stun_trauma, max_stun_trauma)

	# Stun chance increases linearly with trauma.
	var stun_chance = ((stun_trauma / max_stun_trauma)**2) * max_stun_chance

	if randf() < stun_chance:
		_trigger_stun()


func is_stunned() -> bool:
	return stun_time > 0.0


func _trigger_stun() -> void:
	stun_time = stun_duration
	stun_trauma = 0.0


func apply_burn(amount: float, position: Vector2) -> void:
	if burn <= 0.0:
		burn_tick_timer = burn_tick_interval

	burn += amount
	peak_burn = max(peak_burn, burn)

	var local_position = get_parent().to_local(position)
	burn_applied.emit(local_position)
	burn_changed.emit(burn, peak_burn)

func _process(delta: float) -> void:
	#STUN
	if stun_time > 0.0:
		stun_time -= delta
	else:
		stun_trauma = max(stun_trauma - stun_trauma_decay * delta, 0.0)
	
	#BURN
	if burn > 0.0:
		burn_tick_timer -= delta
		if burn_tick_timer <= 0.0:
			health.take_damage(burn, Vector2.ZERO)
			burn = max(burn - burn_decay, 0.0)
			burn_tick_timer = burn_tick_interval
			burn_changed.emit(burn, peak_burn)

		if burn <= 0.0:
			burn_stopped.emit()
			peak_burn = 0.0
