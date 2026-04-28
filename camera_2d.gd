extends Camera2D

var target_zoom = Vector2(1.0, 1.0)
@export var min_zoom = 0.3
@export var max_zoom = 2
@export var zoom_sensitivity = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	target_zoom.x = clamp(target_zoom.x, min_zoom, max_zoom)
	target_zoom.y = clamp(target_zoom.y, min_zoom, max_zoom)

	zoom = lerp(zoom, target_zoom, zoom_sensitivity)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom += Vector2(zoom_sensitivity, zoom_sensitivity)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom -= Vector2(zoom_sensitivity, zoom_sensitivity)
