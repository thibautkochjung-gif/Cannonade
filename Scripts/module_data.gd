class_name ModuleData
extends Resource

enum SlotType {BOW, FORECASTLE, QUARTERDECK, DECK, HOLD, SAIL}

@export_group("Slot")
@export var slot_type: SlotType
@export var display_name: String
@export var description: String

@export_group("Movement Modifiers")
@export var speed_multiplier: float = 1.0
@export var steering_multiplier: float = 1.0

@export_group("Combat Modifiers")
@export var ram_damage_dealt_multiplier: float = 1.0
@export var ram_damage_taken_multiplier: float = 1.0
@export var damage_taken_multiplier: float = 1.0

@export_group("Ammo")
@export var ammo_data: AmmoData  # only used when slot_type == HOLD

@export_group("Behavior")
@export var component_scene: PackedScene  # only used by modules needing active behavior
