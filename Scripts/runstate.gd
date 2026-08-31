extends Node

@export var loadout_layout: ShipLoadoutLayout
@export var default_modules: Array[ModuleData] = []

@export_group("Directional Combat")
@export var front_arc_half_angle: float = PI / 4   # 45°, cone centered on the bow
@export var back_arc_half_angle: float = PI / 4     # 45°, cone centered on the stern

enum HitZone {FRONT, BACK, LEFT, RIGHT}

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


func get_hit_zone(ship: Node2D, hit_direction: Vector2) -> HitZone:
	# hit_direction is the direction the attack was travelling in world
	# space (cannonball velocity, or ram impact direction). Reversing it
	# gives the direction FROM the ship TOWARD the source of the attack,
	# which is what we compare against the ship's own facing.
	var source_direction: Vector2 = -hit_direction
	var forward: Vector2 = ship.transform.x
	var signed_angle: float = forward.angle_to(source_direction)  # (-PI, PI]
	var abs_angle: float = abs(signed_angle)
	
	if abs_angle <= front_arc_half_angle:
		print("Hit from the front")
		return HitZone.FRONT
	if abs_angle >= PI - back_arc_half_angle:
		print("Hit from the back")
		return HitZone.BACK
	
	# Positive angle = source leans toward +transform.y, which is the
	# ship's right/starboard side in Godot's Y-down 2D convention.
	# If left/right come out swapped in testing, flip this comparison.
	if signed_angle > 0.0:
		print("Hit from the right")
		return HitZone.RIGHT
	print("Hit from the left")
	return HitZone.LEFT


func get_directional_damage_taken_multiplier(ship: Node, hit_direction: Vector2) -> float:
	if ship == null or not ship.is_in_group("player") or hit_direction == Vector2.ZERO:
		return 1.0
	
	var ship_2d := ship as Node2D
	if ship_2d == null:
		return 1.0
	
	var field_name: StringName
	match get_hit_zone(ship_2d, hit_direction):
		HitZone.FRONT:
			field_name = &"damage_taken_multiplier_front"
		HitZone.BACK:
			field_name = &"damage_taken_multiplier_back"
		HitZone.LEFT:
			field_name = &"damage_taken_multiplier_left"
		_:
			field_name = &"damage_taken_multiplier_right"
	
	return get_aggregate_multiplier(field_name)


func get_deck_side_for_slot(slot_index: int) -> ShipLoadoutLayout.DeckSide:
	return loadout_layout.get_deck_side(slot_index)
