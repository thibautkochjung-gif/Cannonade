extends Control

@export var reset_advice_button: Button
@export var back_button: Button

func _ready() -> void:
	visible = false
	reset_advice_button.pressed.connect(_on_reset_advice_pressed)
	back_button.pressed.connect(_on_back_pressed)

func open() -> void:
	visible = true

func _on_back_pressed() -> void:
	visible = false

func _on_reset_advice_pressed() -> void:
	Settings.reset_dismissed_advice()
