extends Node2D

enum FxState { GROWING, RECEDING }

@export var burn_fx_scene: PackedScene
@export var status_effects: StatusEffects
@export var min_flame_scale: float = 0.2
@export var max_flame_scale: float = 1.0
@export var growth_duration: float = 5.0
@export var flame_lerp_speed: float = 3.0

var active_fx: Node2D = null
var particle_parents: Array = []
var flame_flows: Array = []

var fx_state: FxState = FxState.GROWING
var growth_elapsed: float = 0.0
var target_flame_scale: float = 0.0
var current_flame_scale: float = 0.0
var despawn_pending: bool = false

func _ready() -> void:
	status_effects.burn_applied.connect(_on_burn_applied)
	status_effects.burn_changed.connect(_on_burn_changed)
	status_effects.burn_stopped.connect(_on_burn_stopped)

func _process(delta: float) -> void:
	if active_fx == null:
		return

	for particle_parent in particle_parents:
		particle_parent.global_rotation = 0.0

	if fx_state == FxState.GROWING:
		growth_elapsed += delta
		var t = clamp(growth_elapsed / growth_duration, 0.0, 1.0)
		current_flame_scale = lerp(min_flame_scale, max_flame_scale, t)
		if t >= 1.0:
			fx_state = FxState.RECEDING
	else:
		current_flame_scale = lerp(
			current_flame_scale, target_flame_scale, 1.0 - exp(-flame_lerp_speed * delta)
		)

	for flame_flow in flame_flows:
		flame_flow.scale = Vector2.ONE * current_flame_scale

	if despawn_pending and current_flame_scale < 0.02:
		_despawn_fx()

func _on_burn_applied(local_position: Vector2) -> void:
	if active_fx != null:
		return

	active_fx = burn_fx_scene.instantiate()
	add_child(active_fx)
	active_fx.position = local_position

	particle_parents = [active_fx]
	flame_flows = active_fx.find_children("*", "", true, false).filter(
		func(node): return node.is_in_group("flame_flow")
	)

	fx_state = FxState.GROWING
	growth_elapsed = 0.0
	current_flame_scale = min_flame_scale
	despawn_pending = false
	for flame_flow in flame_flows:
		flame_flow.scale = Vector2.ONE * min_flame_scale
		flame_flow.restart()
		flame_flow.emitting = true

func _on_burn_changed(current: float, peak: float) -> void:
	if current <= 0.0 or peak <= 0.0:
		target_flame_scale = 0.0
		return
	var ratio = current / peak
	target_flame_scale = lerp(min_flame_scale, max_flame_scale, ratio)

func _on_burn_stopped() -> void:
	target_flame_scale = 0.0
	despawn_pending = true
	for flame_flow in flame_flows:
		flame_flow.emitting = false

func _despawn_fx() -> void:
	active_fx.queue_free()
	active_fx = null
	particle_parents.clear()
	flame_flows.clear()
	despawn_pending = false
	fx_state = FxState.GROWING
	current_flame_scale = 0.0
	target_flame_scale = 0.0
