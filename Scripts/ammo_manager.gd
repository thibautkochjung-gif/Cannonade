class_name AmmoManager
extends Node

signal ammo_changed(ammo: AmmoData)

@export_group("Ammunition")
@export var round_shot: AmmoData
@export var grape_shot: AmmoData
@export var chain_shot: AmmoData
@export var heated_shot: AmmoData

var current_ammo: AmmoData


func _ready() -> void:
	current_ammo = round_shot


func select_ammo(slot: int) -> void:
	match slot:
		1:
			current_ammo = round_shot
		2:
			current_ammo = grape_shot
		3:
			current_ammo = chain_shot
		4:
			current_ammo = heated_shot

	ammo_changed.emit(current_ammo)
