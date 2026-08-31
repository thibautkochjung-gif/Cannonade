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

@export_group("Directional Damage Taken")
@export var damage_taken_multiplier_front: float = 1.0
@export var damage_taken_multiplier_back: float = 1.0
@export var damage_taken_multiplier_left: float = 1.0
@export var damage_taken_multiplier_right: float = 1.0

@export_group("Ammo")
@export var ammo_data: AmmoData  # only used when slot_type == HOLD

@export_group("Deck / Cannon Row")
@export var cannon_scene: PackedScene    # only used when slot_type == DECK
@export var cannon_count: int = 5        # only used when slot_type == DECK

@export_group("Behavior")
@export var component_scene: PackedScene  # only used by modules needing active behavior
