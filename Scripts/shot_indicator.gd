extends Polygon2D
class_name ShotIndicator

@export var fade_time: float = 0.5
@export var max_alpha: float = 0.35
@export var tint: Color = Color(0.714, 0.712, 0.663, 1.0)

var broadside: Node2D
var ammo_manager: AmmoManager
var muzzle_y: float
var min_x: float
var max_x: float
var fade_tween: Tween


func _ready() -> void:
	broadside = get_parent()
	ammo_manager = broadside.get_parent().get_node("AmmoManager")
	_cache_cannon_span()
	visible = false
	modulate.a = 0.0


func _cache_cannon_span() -> void:
	min_x = INF
	max_x = -INF
	var y_sum := 0.0
	var count := 0
	for child in broadside.get_children():
		if child.has_method("cannon_fire"):
			min_x = min(min_x, child.position.x)
			max_x = max(max_x, child.position.x)
			y_sum += child.position.y
			count += 1
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


func _update_shape() -> void:
	var ammo := ammo_manager.current_ammo
	var shot_range := ammo.predicted_range(broadside.shot_strength)
	var half_spread := shot_range * tan(deg_to_rad(ammo.spread_angle) / 2.0)

	var near_left := Vector2(min_x, muzzle_y)
	var near_right := Vector2(max_x, muzzle_y)
	var far_left := Vector2(min_x - half_spread, muzzle_y + shot_range)
	var far_right := Vector2(max_x + half_spread, muzzle_y + shot_range)

	polygon = PackedVector2Array([near_left, near_right, far_right, far_left])

	var near_c := tint
	near_c.a = 1.0
	var far_c := tint
	far_c.a = 0.3
	vertex_colors = PackedColorArray([near_c, near_c, far_c, far_c])
