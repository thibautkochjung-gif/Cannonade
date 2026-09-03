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


func play_broadside(playback: AudioStreamPlaybackPolyphonic, ready_cannons: Array, cannon_count: int, ammo: AmmoData) -> void:
	if playback == null or ready_cannons.is_empty() or cannon_count <= 0:
		return

	var tier := _tier_for(ready_cannons.size(), cannon_count)
	var shots_to_play: int = mini(ready_cannons.size(), tier.shots)

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
		var volume : float = sfx_set.base_volume_db + ammo.sfx_volume_offset_db + tier.volume_db
		var delay := randf_range(stagger_min, stagger_max)

		get_tree().create_timer(delay).timeout.connect(func():
			playback.play_stream(stream, 0.0, volume, pitch, AudioServer.PLAYBACK_TYPE_DEFAULT, bus)
			if ammo.sfx_overlay:
				playback.play_stream(ammo.sfx_overlay, 0.0, ammo.sfx_overlay_volume_db, 1.0, AudioServer.PLAYBACK_TYPE_DEFAULT, bus)
		)
		
