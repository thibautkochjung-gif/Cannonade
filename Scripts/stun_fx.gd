extends Node2D

@export var sprite: Sprite2D
@export var status_effects: StatusEffects

var _stun_tween: Tween
var _base_modulate: Color

func _ready() -> void:
	_base_modulate = sprite.modulate
	status_effects.stun_started.connect(_start_blink)
	status_effects.stun_ended.connect(_stop_blink)

func _start_blink() -> void:
	_stun_tween = create_tween()
	_stun_tween.bind_node(sprite)
	_stun_tween.set_loops()
	_stun_tween.tween_property(sprite, "modulate", Color(1.6, 1.6, 1.6), 0.35)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_stun_tween.tween_property(sprite, "modulate", _base_modulate, 0.35)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _stop_blink() -> void:
	if _stun_tween:
		_stun_tween.kill()
	var reset_tween := create_tween()
	reset_tween.tween_property(sprite, "modulate", _base_modulate, 0.2)
