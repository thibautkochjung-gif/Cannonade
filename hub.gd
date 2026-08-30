extends Control

@export var available_contracts: Array[ContractData] = []
@export var contracts_list: VBoxContainer
@export var loadout_list: VBoxContainer
@export var main_menu_button: Button
@export var contract_details: Control


func _ready() -> void:
	main_menu_button.pressed.connect(GameManagerScene.goto_main_menu)
	_populate_contracts()
	_populate_loadout()


func _populate_contracts() -> void:
	for contract in available_contracts:
		var button := Button.new()
		button.text = "%s\n%s" % [contract.display_name, contract.description]
		button.pressed.connect(func(): contract_details.open(contract))
		contracts_list.add_child(button)


func _populate_loadout() -> void:
	for child in loadout_list.get_children():
		child.queue_free()
	
	for slot_type in ModuleData.SlotType.values():
		var slot_name: String = ModuleData.SlotType.keys()[slot_type]
		var equipped: Array = RunState.get_equipped_modules(slot_type)
		for slot_index in equipped.size():
			var label := _slot_label(slot_type, slot_name, slot_index)
			loadout_list.add_child(_build_slot_row(label, slot_type, slot_index, equipped[slot_index]))


func _slot_label(slot_type: ModuleData.SlotType, slot_name: String, slot_index: int) -> String:
	if slot_type == ModuleData.SlotType.DECK:
		var side: ShipLoadoutLayout.DeckSide = RunState.get_deck_side_for_slot(slot_index)
		var side_name := "Left" if side == ShipLoadoutLayout.DeckSide.LEFT else "Right"
		return "%s (%s)" % [slot_name, side_name]
	return slot_name


func _build_slot_row(label: String, slot_type: ModuleData.SlotType, slot_index: int, module: ModuleData) -> HBoxContainer:
	var row := HBoxContainer.new()
	
	var text_label := Label.new()
	text_label.text = "%s: %s" % [label, module.display_name if module else "(empty)"]
	text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_label)
	
	var change_button := Button.new()
	change_button.text = "Change"
	change_button.pressed.connect(_on_change_slot_pressed.bind(change_button, slot_type, slot_index))
	row.add_child(change_button)
	
	return row


func _on_change_slot_pressed(source_button: Button, slot_type: ModuleData.SlotType, slot_index: int) -> void:
	var candidates: Array[ModuleData] = RunState.get_owned_modules_for_slot(slot_type)
	
	var popup := PopupMenu.new()
	add_child(popup)
	popup.popup_hide.connect(popup.queue_free)
	
	popup.add_item("(empty)", 0)
	for i in candidates.size():
		popup.add_item(candidates[i].display_name, i + 1)
	
	popup.id_pressed.connect(func(id: int):
		var chosen_module: ModuleData = null if id == 0 else candidates[id - 1]
		RunState.set_equipped_module(slot_type, slot_index, chosen_module)
		_populate_loadout()
	)
	
	var below_button := source_button.get_screen_position() + Vector2(0, source_button.size.y)
	popup.position = Vector2i(below_button)
	popup.popup()
