class_name ShipLoadoutLayout
extends Resource

enum DeckSide {LEFT, RIGHT}

@export_group("Slot Counts")
@export var bow_slots: int = 1
@export var forecastle_slots: int = 2
@export var quarterdeck_slots: int = 2
@export var deck_slots_per_side: int = 3
@export var hold_slots: int = 2
@export var sail_slots: int = 2

func get_slot_counts() -> Dictionary:
	return {
		ModuleData.SlotType.BOW: bow_slots,
		ModuleData.SlotType.FORECASTLE: forecastle_slots,
		ModuleData.SlotType.QUARTERDECK: quarterdeck_slots,
		ModuleData.SlotType.DECK: deck_slots_per_side * 2,
		ModuleData.SlotType.HOLD: hold_slots,
		ModuleData.SlotType.SAIL: sail_slots,
	}

func get_deck_side(slot_index: int) -> DeckSide:
	return DeckSide.LEFT if slot_index < deck_slots_per_side else DeckSide.RIGHT
