extends Node
# Autoload name: Sfx

@export var cannon_sfx_sets: Array[CannonSfxSet] = []
@export var max_layered_shots: int = 5              
@export var stagger_min: float = 0.05
@export var stagger_max: float = 0.4
@export var bus: StringName = &"SFX"

@export_group("Volley Tiers")
@export var full_volley_threshold: float = 0.9   # fraction of cannon_count considered "almost full"
@export var medium_tier_min_shots: int = 2
@export var medium_tier_max_shots: int = 4
@export var full_tier_shots: int = 5             # tune this by ear, same as you did for max_layered_shots

@export_group("Volley Volume")
@export var low_tier_volume_db: float = -6.0
@export var medium_tier_volume_db: float = -2.0
@export var full_tier_volume_db: float = 2.0

@export_group("Distance Muffling")
@export var muffle_near_distance: float = 350.0
@export var muffle_far_distance: float = 1400.0
@export var muffle_zoom_near: float = 1.0    # zoom at/above which zoom contributes no muffling
@export var muffle_zoom_far: float = 0.3     # zoom at which zoom alone fully muffles (match camera's min_zoom)
@export var muffle_far_volume_db: float = -10.0
@export var muffle_bus_mid: StringName = &"SFX_Mid"
@export var muffle_bus_far: StringName = &"SFX_Far"

@export_group("Sound Travel Delay")
@export var enable_travel_delay: bool = true
@export var speed_of_sound: float = 900.0    # world units/sec - tuned by ear, not literal 343 m/s
@export var max_travel_delay: float = 1.2    # clamp so very far shots don't feel laggy/unresponsive


var _sets_by_class: Dictionary = {}


func _ready() -> void:
	for sfx_set in cannon_sfx_sets:
		_sets_by_class[sfx_set.cannon_class] = sfx_set


func _tier_for(shots_fired: int, cannon_count: int) -> Dictionary:
	if shots_fired <= 1:
		return {shots = 1, volume_db = low_tier_volume_db}
	
	var full_volley_shots := int(ceil(cannon_count * full_volley_threshold))
	if shots_fired >= full_volley_shots:
		return {shots = full_tier_shots, volume_db = full_tier_volume_db}
	
	var t := float(shots_fired - 2) / float(maxi(full_volley_shots - 2, 1))
	var shots := int(round(lerp(float(medium_tier_min_shots), float(medium_tier_max_shots), clampf(t, 0.0, 1.0))))
	return {shots = shots, volume_db = medium_tier_volume_db}


func play_broadside(playback: AudioStreamPlaybackPolyphonic, ready_cannons: Array, cannon_count: int, ammo: AmmoData, source_position: Vector2) -> void:  
	if playback == null or ready_cannons.is_empty() or cannon_count <= 0:
		return
	
	var tier := _tier_for(ready_cannons.size(), cannon_count)
	var shots_to_play: int = mini(ready_cannons.size(), tier.shots)
	var muffle := _muffle_for(source_position) 
	
	var sample: Array = ready_cannons.duplicate()
	sample.shuffle()
	sample = sample.slice(0, shots_to_play)
	
	for cannon in sample:
		var sfx_set: CannonSfxSet = _sets_by_class.get(cannon.cannon_class)
		if sfx_set == null or sfx_set.sounds.is_empty():
			continue
		
		var stream: AudioStream = sfx_set.sounds.pick_random()
		var pitch := sfx_set.base_pitch + ammo.sfx_pitch_offset \
			+ randf_range(-sfx_set.pitch_variance, sfx_set.pitch_variance)
		var volume : float = sfx_set.base_volume_db + ammo.sfx_volume_offset_db + tier.volume_db + muffle.volume_db  # CHANGED
		var delay : float = randf_range(stagger_min, stagger_max) + muffle.delay  # CHANGED
		
		get_tree().create_timer(delay).timeout.connect(func():
			playback.play_stream(stream, 0.0, volume, pitch, AudioServer.PLAYBACK_TYPE_DEFAULT, muffle.bus)  # CHANGED: was `bus`
			if ammo.sfx_overlay:
				playback.play_stream(ammo.sfx_overlay, 0.0, ammo.sfx_overlay_volume_db, 1.0, AudioServer.PLAYBACK_TYPE_DEFAULT, muffle.bus)  # CHANGED
		)


func _muffle_for(source_position: Vector2) -> Dictionary:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return {bus = bus, volume_db = 0.0, delay = 0.0}
	
	var zoom_avg: float = (cam.zoom.x + cam.zoom.y) * 0.5
	var raw_distance: float = cam.global_position.distance_to(source_position)
	
	var distance_farness: float = clampf(
		inverse_lerp(muffle_near_distance, muffle_far_distance, raw_distance), 0.0, 1.0
	)
	var zoom_farness: float = clampf(
		inverse_lerp(muffle_zoom_near, muffle_zoom_far, zoom_avg), 0.0, 1.0
	)
	var farness: float = 1.0 - (1.0 - distance_farness) * (1.0 - zoom_farness)  # either factor alone can drive this
	
	var chosen_bus: StringName = bus
	if farness > 0.66:
		chosen_bus = muffle_bus_far
	elif farness > 0.33:
		chosen_bus = muffle_bus_mid
	
	var travel_delay: float = 0.0
	if enable_travel_delay:
		travel_delay = clampf(raw_distance / speed_of_sound, 0.0, max_travel_delay)  # distance only, not zoom-blended
	
	return {bus = chosen_bus, volume_db = lerp(0.0, muffle_far_volume_db, farness), delay = travel_delay}
