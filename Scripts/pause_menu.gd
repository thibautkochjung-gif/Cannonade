extends CanvasLayer

@export var pause_panel: Control
@export var resume_button: Button
@export var restart_button: Button
@export var main_menu_button: Button
@export var help_overlay: CanvasLayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if help_overlay.visible:
		return
	if not event.is_action_pressed("ui_cancel"):
		return
	if visible:
		_close()
	else:
		_open()
	get_viewport().set_input_as_handled()


func _open() -> void:
	get_tree().paused = true
	visible = true
	pause_panel.visible = true


func _close() -> void:
	get_tree().paused = false
	visible = false


func _on_resume_pressed() -> void:
	_close()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	GameManagerScene.start_contract(RunState.active_contract)


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	GameManagerScene.goto_main_menu()
