extends CanvasLayer

@export var advice_id: String = "ammo_reminder"
@export var panel: Control
@export var dont_remind_checkbox: CheckBox
@export var close_button: Button
@export var reminder_timer: Timer

const REMINDER_DELAY_MINUTES := 2.0

var _ammo_manager: AmmoManager

func _ready() -> void:
	panel.visible = false
	reminder_timer.one_shot = true
	reminder_timer.wait_time = REMINDER_DELAY_MINUTES * 60.0
	reminder_timer.timeout.connect(_on_reminder_timeout)
	close_button.pressed.connect(_on_close_pressed)
	dont_remind_checkbox.toggled.connect(_on_dont_remind_toggled)

func connect_to_player(player: Node) -> void:
	_ammo_manager = player.ammo_manager
	_ammo_manager.ammo_changed.connect(_on_ammo_changed)
	_maybe_arm_timer()

func _maybe_arm_timer() -> void:
	if not Settings.should_show_advice(advice_id):
		return
	if _ammo_manager.get_available_ammo_count() <= 1:
		return
	reminder_timer.start()

func _on_ammo_changed(_ammo: AmmoData) -> void:
	if not panel.visible:
		reminder_timer.start()

func _on_reminder_timeout() -> void:
	if Settings.should_show_advice(advice_id):
		panel.visible = true

func _on_close_pressed() -> void:
	panel.visible = false
	_maybe_arm_timer()

func _on_dont_remind_toggled(pressed: bool) -> void:
	if pressed:
		Settings.dismiss_advice(advice_id)
