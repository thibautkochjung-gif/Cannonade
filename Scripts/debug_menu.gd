extends CanvasLayer

const GOD_MODE_SPEED_MULTIPLIER := 15.0

var panel: PanelContainer
var god_mode_check: CheckButton
var health_bars_check: CheckButton
var module_option: OptionButton
var contract_option: OptionButton

var god_mode_enabled := false
var health_bars_enabled := false

var _available_modules: Array[ModuleData] = []
var _available_contracts: Array[ContractData] = []


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return

	layer = 100
	_available_modules = _load_modules()
	_available_contracts = _load_contracts()
	_build_ui()
	panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_P:
		panel.visible = not panel.visible


func _process(_delta: float) -> void:
	var player := GameManagerScene.player
	if player:
		player.set("debug_speed_multiplier", GOD_MODE_SPEED_MULTIPLIER if god_mode_enabled else 1.0)

	if health_bars_enabled:
		_ensure_health_bars_attached()


func _build_ui() -> void:
	panel = PanelContainer.new()
	panel.position = Vector2(20, 20)
	add_child(panel)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "DEBUG MENU (P to close)"
	vbox.add_child(title)

	god_mode_check = CheckButton.new()
	god_mode_check.text = "God Mode (speed x%s)" % GOD_MODE_SPEED_MULTIPLIER
	god_mode_check.toggled.connect(_on_god_mode_toggled)
	vbox.add_child(god_mode_check)

	health_bars_check = CheckButton.new()
	health_bars_check.text = "Show Health Bars"
	health_bars_check.toggled.connect(_on_health_bars_toggled)
	vbox.add_child(health_bars_check)

	vbox.add_child(HSeparator.new())

	vbox.add_child(_label("Grant Module"))
	var module_row := HBoxContainer.new()
	vbox.add_child(module_row)
	module_option = OptionButton.new()
	for module in _available_modules:
		module_option.add_item(module.display_name)
	module_row.add_child(module_option)
	var grant_button := Button.new()
	grant_button.text = "Grant"
	grant_button.pressed.connect(_on_grant_module_pressed)
	module_row.add_child(grant_button)

	vbox.add_child(HSeparator.new())

	vbox.add_child(_label("Enter Contract"))
	var contract_row := HBoxContainer.new()
	vbox.add_child(contract_row)
	contract_option = OptionButton.new()
	for contract in _available_contracts:
		contract_option.add_item(contract.display_name)
	contract_row.add_child(contract_option)
	var enter_button := Button.new()
	enter_button.text = "Enter"
	enter_button.pressed.connect(_on_enter_contract_pressed)
	contract_row.add_child(enter_button)


func _label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	return label


func _on_god_mode_toggled(pressed: bool) -> void:
	god_mode_enabled = pressed


func _on_health_bars_toggled(pressed: bool) -> void:
	health_bars_enabled = pressed
	for bar in get_tree().get_nodes_in_group("debug_health_bar"):
		bar.visible = pressed


func _on_grant_module_pressed() -> void:
	if _available_modules.is_empty() or module_option.selected < 0:
		return
	var module := _available_modules[module_option.selected]
	RunState.grant_module(module)
	print("Debug: granted module '%s'" % module.display_name)


func _on_enter_contract_pressed() -> void:
	if _available_contracts.is_empty() or contract_option.selected < 0:
		return
	var contract := _available_contracts[contract_option.selected]
	GameManagerScene.start_contract(contract)


func _ensure_health_bars_attached() -> void:
	for ship in get_tree().get_nodes_in_group("ship"):
		if ship.get_node_or_null("DebugHealthBar") != null:
			continue
		var health := ship.get_node_or_null("Health") as Health
		if health == null:
			continue
		var bar := DebugHealthBar.new()
		bar.name = "DebugHealthBar"
		ship.add_child(bar)
		bar.setup(health)
		bar.visible = health_bars_enabled


func _load_modules() -> Array[ModuleData]:
	var results: Array[ModuleData] = []
	_scan_modules("res://Resources/Modules", results)
	return results


func _scan_modules(path: String, results: Array[ModuleData]) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		var full_path := path.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with("."):
				_scan_modules(full_path, results)
		elif entry.ends_with(".tres"):
			var resource := ResourceLoader.load(full_path)
			if resource is ModuleData:
				results.append(resource)
		entry = dir.get_next()
	dir.list_dir_end()


func _load_contracts() -> Array[ContractData]:
	var results: Array[ContractData] = []
	_scan_contracts("res://Resources/Contracts", results)
	return results


func _scan_contracts(path: String, results: Array[ContractData]) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		var full_path := path.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with("."):
				_scan_contracts(full_path, results)
		elif entry.ends_with(".tres"):
			var resource := ResourceLoader.load(full_path)
			if resource is ContractData:
				results.append(resource)
		entry = dir.get_next()
	dir.list_dir_end()
