extends Node

@onready var map_root: Node2D = $MapRoot
@onready var enemy_spawner = $EnemySpawner

func _ready() -> void:
	GameManagerScene.world_root = self

	var contract: ContractData = RunState.active_contract
	if contract == null:
		push_error("game_root: RunState.active_contract is not set - nothing to load")
		return
	
	_load_map(contract)
	enemy_spawner.spawn_all(contract.enemy_scenes)
	_start_objective(contract)


func _load_map(contract: ContractData) -> void:
	var map := contract.map_scene.instantiate()
	map_root.add_child(map)


func _start_objective(contract: ContractData) -> void:
	if contract.objective == null or contract.objective.controller_scene == null:
		push_warning("game_root: contract '%s' has no objective set" % contract.display_name)
		return

	var controller = contract.objective.controller_scene.instantiate()
	add_child(controller)
	controller.setup(contract.objective)
	controller.objective_completed.connect(GameManagerScene.trigger_victory)
