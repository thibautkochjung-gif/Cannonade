extends Node

@export var loadout_layout: ShipLoadoutLayout
@export var default_modules: Array[ModuleData] = []

var active_contract: ContractData
var equipped_loadout: Dictionary = {}
var owned_modules: Array[ModuleData] = []


func _ready() -> void:
	_initialize_slots()
	_apply_default_modules()


func _initialize_slots() -> void:
	for slot_type in loadout_layout.get_slot_counts():
		var count: int = loadout_layout.get_slot_counts()[slot_type]
		equipped_loadout[slot_type] = []
		equipped_loadout[slot_type].resize(count)


func _apply_default_modules() -> void:
	for module in default_modules:
		grant_module(module)
		_equip_in_first_open_slot(module)


func _equip_in_first_open_slot(module: ModuleData) -> void:
	var slots: Array = equipped_loadout.get(module.slot_type)
	if slots == null:
		push_warning("RunState: no slot array for slot_type %s" % module.slot_type)
		return
	for i in slots.size():
		if slots[i] == null:
			slots[i] = module
			return
	push_warning("RunState: no empty slot for module %s" % module.display_name)


func get_equipped_modules(slot_type: ModuleData.SlotType) -> Array:
	return equipped_loadout.get(slot_type, [])


func set_equipped_module(slot_type: ModuleData.SlotType, slot_index: int, module: ModuleData) -> void:
	var slots: Array = equipped_loadout.get(slot_type)
	if slots == null or slot_index < 0 or slot_index >= slots.size():
		push_warning("RunState: invalid slot %s[%d]" % [slot_type, slot_index])
		return
	slots[slot_index] = module


func grant_module(module: ModuleData) -> void:
	if module != null and not owned_modules.has(module):
		owned_modules.append(module)


func get_owned_modules_for_slot(slot_type: ModuleData.SlotType) -> Array[ModuleData]:
	var result: Array[ModuleData] = []
	for module in owned_modules:
		if module.slot_type == slot_type:
			result.append(module)
	return result


func get_aggregate_multiplier(field_name: StringName) -> float:
	var result := 1.0
	for slot_type in equipped_loadout:
		for module in equipped_loadout[slot_type]:
			if module != null:
				result *= module.get(field_name)
	return result

func get_multiplier_for(ship: Node, field_name: StringName) -> float:
	if ship == null or not ship.is_in_group("player"):
		return 1.0
	return get_aggregate_multiplier(field_name)


func get_deck_side_for_slot(slot_index: int) -> ShipLoadoutLayout.DeckSide:
	return loadout_layout.get_deck_side(slot_index)
