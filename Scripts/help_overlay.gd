extends CanvasLayer

const HUD_SCENE := preload("res://Nodes/hud.tscn")
const LABEL_GAP := 20.0
const LINE_COLOR := Color(1, 1, 1, 0.7)

enum AnnotationStyle { INSIDE_LEFT, RIGHT, ABOVE_LEFT, ABOVE_CENTER, BELOW_CENTER }

const TOUR_ENTRIES := [
	{"target": "health_indicator", "text": "Hull health", "style": AnnotationStyle.INSIDE_LEFT},
	{"target": "sail_condition_indicator", "text": "Sail condition", "style": AnnotationStyle.INSIDE_LEFT},
	{"target": "mast_state_indicator", "text": "Mast state", "style": AnnotationStyle.RIGHT},
	{"target": "right_broadside_indicator", "text": "Right cannons reload", "style": AnnotationStyle.ABOVE_LEFT},
	{"target": "left_broadside_indicator", "text": "Left cannons reload", "style": AnnotationStyle.ABOVE_LEFT},
	{"target": "survival_timer_label", "text": "Time survived", "style": AnnotationStyle.BELOW_CENTER},
]

@onready var _annotation_container: Control = $AnnotationContainer

var _resume_on_close: bool = false
var _hud_preview: HUD = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	open()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("toggle_help"):
		return
	if visible:
		close()
	else:
		open()
	get_viewport().set_input_as_handled()

func open() -> void:
	if visible:
		return
	_resume_on_close = not get_tree().paused
	get_tree().paused = true
	visible = true
	_build_hud_tour()

func close() -> void:
	if not visible:
		return
	visible = false
	if _resume_on_close:
		get_tree().paused = false
	_teardown_hud_tour()

func _build_hud_tour() -> void:
	_hud_preview = HUD_SCENE.instantiate()
	add_child(_hud_preview)
	move_child(_hud_preview, 0)  # stay under ColorRect / AnnotationContainer

	# SurvivalTimerLabel is hidden by default; Containers skip hidden
	# children when laying out — force it visible before measuring.
	_hud_preview.survival_timer_label.visible = true

	await get_tree().process_frame  # let containers finish sizing before measuring

	if not is_instance_valid(_hud_preview):
		return  # overlay was closed again before this frame landed

	for entry in TOUR_ENTRIES:
		var target: Control = _hud_preview.get(entry["target"])
		_annotate(target, entry["text"], entry["style"])

func _annotate(target: Control, text: String, style: AnnotationStyle) -> void:
	var rect := target.get_global_rect()

	var label := Label.new()
	label.text = text
	_annotation_container.add_child(label)

	var anchor_point: Vector2
	var line_end: Vector2
	var draw_line := true

	match style:
		AnnotationStyle.INSIDE_LEFT:
			label.add_theme_color_override("font_color", Color.WHITE)
			label.add_theme_color_override("font_outline_color", Color.BLACK)
			label.add_theme_constant_override("outline_size", 3)
			label.reset_size()
			label.position = rect.position + Vector2(6, rect.size.y * 0.5 - label.size.y * 0.5)
			draw_line = false

		AnnotationStyle.RIGHT:
			label.reset_size()
			label.position = Vector2(
				rect.position.x + rect.size.x + LABEL_GAP,
				rect.position.y + rect.size.y * 0.5 - label.size.y * 0.5
			)
			anchor_point = Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y * 0.5)
			line_end = Vector2(label.position.x, label.position.y + label.size.y * 0.5)

		AnnotationStyle.ABOVE_LEFT:
			label.reset_size()
			label.position = rect.position + Vector2(0, -24)
			anchor_point = rect.position
			line_end = Vector2(label.position.x, label.position.y + label.size.y)

		AnnotationStyle.ABOVE_CENTER:
			label.reset_size()
			label.position = Vector2(
				rect.position.x + rect.size.x * 0.5 - label.size.x * 0.5,
				rect.position.y - LABEL_GAP - label.size.y
			)
			anchor_point = Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y)
			line_end = Vector2(label.position.x + label.size.x * 0.5, label.position.y + label.size.y)

		AnnotationStyle.BELOW_CENTER:
			label.reset_size()
			label.position = Vector2(
				rect.position.x + rect.size.x * 0.5 - label.size.x * 0.5,
				rect.position.y + rect.size.y + LABEL_GAP
			)
			anchor_point = Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y + rect.size.y)
			line_end = Vector2(label.position.x + label.size.x * 0.5, label.position.y)

	if draw_line:
		_draw_connector(anchor_point, line_end, label)

func _draw_connector(from: Vector2, to: Vector2, in_front_of: Label) -> void:
	var line := Line2D.new()
	line.width = 1.5
	line.antialiased = true
	line.default_color = LINE_COLOR
	line.points = PackedVector2Array([from, to])
	_annotation_container.add_child(line)
	_annotation_container.move_child(line, in_front_of.get_index())  # draw behind its label

func _teardown_hud_tour() -> void:
	for child in _annotation_container.get_children():
		child.queue_free()
	if is_instance_valid(_hud_preview):
		_hud_preview.queue_free()
	_hud_preview = null
