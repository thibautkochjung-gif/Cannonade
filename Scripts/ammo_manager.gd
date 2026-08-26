class_name AmmoManager
extends Node

signal ammo_changed(ammo: AmmoData)

const HOLD_SLOT_FOR_KEY := {1: 0, 2: 1}

var current_ammo: AmmoData


func _ready() -> void:
	_select_from_hold_slot(0)


func select_ammo(slot: int) -> void:
	if not HOLD_SLOT_FOR_KEY.has(slot):
		return
	_select_from_hold_slot(HOLD_SLOT_FOR_KEY[slot])


func _select_from_hold_slot(hold_index: int) -> void:
	var hold_modules: Array = RunState.get_equipped_modules(ModuleData.SlotType.HOLD)
	if hold_index >= hold_modules.size():
		return
	var module: ModuleData = hold_modules[hold_index]
	if module == null or module.ammo_data == null:
		return
	current_ammo = module.ammo_data
	ammo_changed.emit(current_ammo)
