class_name ContractData
extends Resource

@export var display_name: String
@export var description: String

@export_group("Map")
@export var map_scene: PackedScene

@export_group("Enemies")
@export var enemy_scenes: Array[PackedScene] = []

@export_group("Objective")
@export var objective: ObjectiveData

@export_group("Reward")
@export var reward_modules: Array[ModuleData] = []  # inert until Phase 7
