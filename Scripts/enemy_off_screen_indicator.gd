extends Control

## Draws a triangular indicator at the screen edge for every enemy that is
## currently outside the camera's view. Indicators shrink with distance so a
## far-away enemy reads as "far" and a close one reads as "near".
##
## Attach this to a full-rect Control living under the HUD's CanvasLayer.
## Assign `indicator_texture` in the Inspector once you have the PNG.

@export var indicator_texture: Texture2D
@export var indicator_size: Vector2 = Vector2(32, 32)
@export var edge_margin: float = 48.0  # keeps the indicator's center this far from the screen border

@export_group("Distance Scaling")
@export var min_distance: float = 300.0   # at or below this distance from the camera -> max_scale
@export var max_distance: float = 3000.0  # at or above this distance from the camera -> min_scale
@export var min_scale: float = 0.4
@export var max_scale: float = 1.3

## If your triangle PNG doesn't point along +X (0 degrees) by default,
## use this to line the tip up with the direction to the enemy.
@export var rotation_offset_degrees: float = 0.0

var _camera: Camera2D
var _indicators: Dictionary = {}  # enemy Node2D -> TextureRect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	if not is_instance_valid(_camera):
		_camera = get_viewport().get_camera_2d()
		if _camera == null:
			return

	var active_enemies: Dictionary = {}

	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue
		active_enemies[enemy] = true
		_update_indicator_for(enemy)

	_cleanup_stale_indicators(active_enemies)


func _update_indicator_for(enemy: Node2D) -> void:
	var viewport_size := get_viewport_rect().size
	var screen_pos: Vector2 = get_viewport().canvas_transform * enemy.global_position

	var is_offscreen := screen_pos.x < 0.0 or screen_pos.x > viewport_size.x \
		or screen_pos.y < 0.0 or screen_pos.y > viewport_size.y

	if not is_offscreen:
		if _indicators.has(enemy):
			_indicators[enemy].hide()
		return

	var indicator := _get_or_create_indicator(enemy)
	indicator.show()

	var center := viewport_size * 0.5
	var direction := (screen_pos - center).normalized()

	indicator.position = _clamp_to_screen_edge(center, direction, viewport_size) - indicator.size * 0.5
	indicator.rotation = direction.angle() + deg_to_rad(rotation_offset_degrees)
	indicator.scale = Vector2.ONE * _scale_for_distance(enemy)


func _scale_for_distance(enemy: Node2D) -> float:
	var distance := _camera.global_position.distance_to(enemy.global_position)
	var t: float = clamp(inverse_lerp(min_distance, max_distance, distance), 0.0, 1.0)
	return lerp(max_scale, min_scale, t)


func _clamp_to_screen_edge(center: Vector2, direction: Vector2, viewport_size: Vector2) -> Vector2:
	var half := viewport_size * 0.5 - Vector2.ONE * edge_margin
	var scale_x: float = INF if direction.x == 0.0 else half.x / abs(direction.x)
	var scale_y: float = INF if direction.y == 0.0 else half.y / abs(direction.y)
	return center + direction * min(scale_x, scale_y)


func _get_or_create_indicator(enemy: Node2D) -> TextureRect:
	if _indicators.has(enemy):
		return _indicators[enemy]

	var rect := TextureRect.new()
	rect.texture = indicator_texture
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.size = indicator_size
	rect.pivot_offset = indicator_size * 0.5
	add_child(rect)

	_indicators[enemy] = rect
	return rect


func _cleanup_stale_indicators(active_enemies: Dictionary) -> void:
	for enemy in _indicators.keys():
		if is_instance_valid(enemy) and active_enemies.has(enemy):
			continue
		if is_instance_valid(_indicators[enemy]):
			_indicators[enemy].queue_free()
		_indicators.erase(enemy)
