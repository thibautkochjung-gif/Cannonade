extends Polygon2D
class_name ShotIndicator

@export var fade_time: float = 0.5
@export var max_alpha: float = 0.35
@export var tint: Color = Color(0.714, 0.712, 0.663, 1.0)

@export_group("Mixed Cannon Type Display")
@export var inner_line_alpha: float = 0.9
@export var dash_length: float = 6.0
@export var dash_width: float = 3.0

var broadside: Node2D
var ammo_manager: AmmoManager
var muzzle_y: float
var min_x: float
var max_x: float
var distinct_cannon_profiles: Array[Vector2] = []  # x = velocity_multiplier, y = flight_time_multiplier
var fade_tween: Tween
var _inner_range_depths: Array[float] = []  # ranges shorter than the max, for the dashed lines


func _ready() -> void:
	broadside = get_parent()
	ammo_manager = broadside.get_parent().get_node("AmmoManager")
	rebuild_cannon_span()
	visible = false
	modulate.a = 0.0


func rebuild_cannon_span() -> void:
	min_x = INF
	max_x = -INF
	var y_sum := 0.0
	var count := 0
	distinct_cannon_profiles.clear()

	for cannon in broadside.find_children("*", "", true, false):
		if not cannon.has_method("cannon_fire"):
			continue
		var local_position: Vector2 = broadside.to_local(cannon.global_position)
		min_x = min(min_x, local_position.x)
		max_x = max(max_x, local_position.x)
		y_sum += local_position.y
		count += 1
		var profile := Vector2(cannon.velocity_multiplier, cannon.flight_time_multiplier)
		if not distinct_cannon_profiles.has(profile):
			distinct_cannon_profiles.append(profile)

	muzzle_y = y_sum / count if count > 0 else 0.0


func show_indicator() -> void:
	visible = true
	_restart_fade(max_alpha)


func hide_indicator() -> void:
	_restart_fade(0.0)


func _restart_fade(target_alpha: float) -> void:
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", target_alpha, fade_time)
	if target_alpha == 0.0:
		fade_tween.tween_callback(func(): visible = false)


func _process(_delta: float) -> void:
	if not visible:
		return
	_update_shape()
	queue_redraw()


func _update_shape() -> void:
	_inner_range_depths.clear()

	if distinct_cannon_profiles.is_empty():
		polygon = PackedVector2Array()
		return

	var ammo := ammo_manager.current_ammo

	# One range per distinct cannon type present on this broadside.
	var ranges: Array[float] = []
	for profile in distinct_cannon_profiles:
		ranges.append(ammo.predicted_range(broadside.shot_strength * profile.x, profile.y))

	var max_range: float = ranges.max()
	var half_spread := max_range * tan(deg_to_rad(ammo.spread_angle) / 2.0)

	var near_left := Vector2(min_x, muzzle_y)
	var near_right := Vector2(max_x, muzzle_y)
	var far_left := Vector2(min_x - half_spread, muzzle_y + max_range)
	var far_right := Vector2(max_x + half_spread, muzzle_y + max_range)

	polygon = PackedVector2Array([near_left, near_right, far_right, far_left])

	var near_c := tint
	near_c.a = 1.0
	var far_c := tint
	far_c.a = 0.3
	vertex_colors = PackedColorArray([near_c, near_c, far_c, far_c])

	# Every shorter-ranged type present gets a dashed line inside the trapezoid.
	for r in ranges:
		if r < max_range:
			_inner_range_depths.append(r)


func _draw() -> void:
	if _inner_range_depths.is_empty():
		return

	var ammo := ammo_manager.current_ammo
	var dash_color := tint
	dash_color.a = inner_line_alpha

	for r in _inner_range_depths:
		var inner_half_spread := r * tan(deg_to_rad(ammo.spread_angle) / 2.0)
		var from := Vector2(min_x - inner_half_spread, muzzle_y + r)
		var to := Vector2(max_x + inner_half_spread, muzzle_y + r)
		draw_dashed_line(from, to, dash_color, dash_width, dash_length, true)
