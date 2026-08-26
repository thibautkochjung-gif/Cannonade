extends Node

@export var boost_speed_multiplier: float = 1.5
@export var boost_duration: float = 2.0
@export var cooldown_time: float = 20.0

var ship: CharacterBody2D
var status_effects: StatusEffects
var can_activate: bool = true


func _ready() -> void:
	ship = get_parent()
	status_effects = ship.get_node("StatusEffects")
	$BoostTimer.wait_time = boost_duration
	$CooldownTimer.wait_time = cooldown_time


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("boost_speed"):
		return
	if not can_activate or status_effects.is_stunned():
		return
	_activate_boost()


func _activate_boost() -> void:
	can_activate = false
	ship.set("boost_multiplier", boost_speed_multiplier)
	$BoostTimer.start()


func _on_boost_timer_timeout() -> void:
	ship.set("boost_multiplier", 1.0)
	$CooldownTimer.start()



func _on_cooldown_timer_timeout() -> void:
	can_activate = true
