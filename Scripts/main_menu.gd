extends Control

@export var new_game_button: Button
@export var exit_button: Button
@export var settings_button: Button
@export var settings_menu: Control


func _ready() -> void:
	new_game_button.pressed.connect(GameManagerScene.goto_hub)
	exit_button.pressed.connect(GameManagerScene.quit_game)
	settings_button.pressed.connect(_on_settings_pressed)


func _on_settings_pressed() -> void:
	settings_menu.open()
