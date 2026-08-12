extends Node2D
@export var health : Health
@export var damage_fx_scene : PackedScene
@export var burst_reset_timer : Timer

var in_burst : bool = false

func _ready() -> void:
	health.health_changed.connect(_on_health_changed)

func _on_health_changed(amount, max_health, current_health, hit_direction, source, fx_trigger_chance) -> void:
	var should_trigger = false
	if not in_burst:
		should_trigger = true
		in_burst = true
	elif randf() <= fx_trigger_chance:
		should_trigger = true
	
	burst_reset_timer.start()
	
	if should_trigger:
		var dmg_fx = damage_fx_scene.instantiate()
		dmg_fx.global_position = global_position
		get_tree().current_scene.add_child(dmg_fx)
		dmg_fx.setup(hit_direction)

func _on_burst_reset_timer_timeout() -> void:
	in_burst = false
