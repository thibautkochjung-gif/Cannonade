extends Node

@export var loadout_layout: ShipLoadoutLayout
@export var default_modules: Array[ModuleData] = []

var equipped_loadout: Dictionary = {}

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
