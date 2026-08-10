extends Node2D

@export var max_emission_rate := 100.0
@export var size_multiplier := 1.0

var base_scale_min: float
var base_scale_max: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_scale_min = $WakeParticles.process_material.scale_min * size_multiplier
	base_scale_max = $WakeParticles.process_material.scale_max * size_multiplier
	$WakeParticles.process_material.scale_min = base_scale_min
	$WakeParticles.process_material.scale_max = base_scale_max


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_speed(speed_ratio: float) -> void:
	$WakeParticles.speed_scale = speed_ratio
	$WakeParticles.process_material.scale_min = base_scale_min * sqrt(speed_ratio)
	$WakeParticles.process_material.scale_max = base_scale_max * sqrt(speed_ratio)
