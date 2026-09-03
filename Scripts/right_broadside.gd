extends Node2D
class_name RightBroadside

@export var shot_delay_max = 0.2
@export var shot_strength = 700

@onready var shot_indicator: ShotIndicator = get_node_or_null("ShotIndicator")
@onready var shot_audio: AudioStreamPlayer2D = $ShotAudio

var shot_playback: AudioStreamPlaybackPolyphonic

var cannons: Array = []
var cannon_count: int
var cannon_ready_count: int
var cannon_ready_percentage: float
var ammo_manager: AmmoManager

signal fired(amount: int, direction: Vector2)
signal reload_percentage_changed(new_percentage)


func _ready() -> void:
	rebuild_cannons()
	ammo_manager = _find_ship_ancestor().get_node("AmmoManager")
	shot_audio.stream = AudioStreamPolyphonic.new() 
	shot_audio.play()
	shot_playback = shot_audio.get_stream_playback()


func _find_ship_ancestor() -> Node2D:
	var node := get_parent()
	while node != null and not node.is_in_group("ship"):
		node = node.get_parent()
	return node


func rebuild_cannons() -> void:
	for cannon in cannons:
		if cannon.ready_to_fire_signal.is_connected(_on_cannon_ready):
			cannon.ready_to_fire_signal.disconnect(_on_cannon_ready)
	
	cannons = find_children("*", "", true, false).filter(func(c): return c.has_method("cannon_fire"))
	cannon_count = cannons.size()
	cannon_ready_count = cannon_count
	cannon_ready_percentage = float(cannon_ready_count) / cannon_count if cannon_count > 0 else 0.0
	
	for cannon in cannons:
		cannon.ready_to_fire_signal.connect(_on_cannon_ready)
	
	if shot_indicator:
		shot_indicator.rebuild_cannon_span()


func fire():
	var ready_cannons: Array = cannons.filter(func(c): return c.ready_to_fire)  # NEW
	Sfx.play_broadside(shot_playback, ready_cannons, cannon_count, ammo_manager.current_ammo)
	for cannon in cannons:
		var delay = randf_range(0.0, shot_delay_max)
		get_tree().create_timer(delay).timeout.connect(func(c = cannon): c.cannon_fire(self))
	fired.emit(cannon_ready_count, -global_transform.y)
	cannon_ready_count = 0
	reload_percentage_changed.emit(0.0)
	if shot_indicator:
		shot_indicator.hide_indicator()


func _on_cannon_ready() -> void:
	cannon_ready_count += 1
	cannon_ready_percentage = float(cannon_ready_count) / cannon_count if cannon_count > 0 else 0.0
	reload_percentage_changed.emit(cannon_ready_percentage)


func show_aim() -> void:
	if shot_indicator:
		shot_indicator.show_indicator()


func hide_aim() -> void:
	if shot_indicator:
		shot_indicator.hide_indicator()
