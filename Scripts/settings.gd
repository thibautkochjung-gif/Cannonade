extends Node

const SETTINGS_PATH := "user://settings.cfg"
const SECTION := "gameplay"

var advice_enabled: bool = true
var _dismissed_advice: Dictionary = {}  # advice_id (String) -> true


func _ready() -> void:
	_load()


func set_advice_enabled(value: bool) -> void:
	advice_enabled = value
	_save()


func dismiss_advice(advice_id: String) -> void:
	_dismissed_advice[advice_id] = true
	_save()


func reset_dismissed_advice() -> void:
	_dismissed_advice.clear()
	_save()


func should_show_advice(advice_id: String) -> bool:
	return advice_enabled and not _dismissed_advice.get(advice_id, false)


func _load() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		advice_enabled = config.get_value(SECTION, "advice_enabled", true)
		for id in config.get_value(SECTION, "dismissed_advice", []):
			_dismissed_advice[id] = true


func _save() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value(SECTION, "advice_enabled", advice_enabled)
	config.set_value(SECTION, "dismissed_advice", _dismissed_advice.keys())
	config.save(SETTINGS_PATH)
