extends CanvasLayer

@export var restart_button: Button
@export var exit_button: Button
@export var reward_header: Label
@export var reward_options_container: HBoxContainer

const REWARD_CHOICE_COUNT := 3


func _ready() -> void:
	restart_button.pressed.connect(func(): GameManagerScene.start_contract(RunState.active_contract))
	exit_button.pressed.connect(GameManagerScene.goto_hub)
	_populate_rewards()


func _populate_rewards() -> void:
	var contract : ContractData = RunState.active_contract
	if contract == null or contract.reward_modules.is_empty():
		reward_header.visible = false
		return

	var pool := _get_reward_pool(contract)
	if pool.is_empty():
		reward_header.text = "No new rewards available."
		return

	restart_button.disabled = true
	exit_button.disabled = true

	var choices := pool.duplicate()
	choices.shuffle()
	choices = choices.slice(0, min(REWARD_CHOICE_COUNT, choices.size()))

	for module in choices:
		var button := Button.new()
		button.text = "%s\n%s" % [module.display_name, module.description]
		button.pressed.connect(_on_reward_chosen.bind(module))
		reward_options_container.add_child(button)


func _get_reward_pool(contract: ContractData) -> Array[ModuleData]:
	var pool: Array[ModuleData] = []
	for module in contract.reward_modules:
		# Cannon rows can always reappear (a ship mounts several of the same
		# row); everything else drops out of the pool once it's owned.
		if not RunState.owned_modules.has(module):
			pool.append(module)
	return pool


func _on_reward_chosen(module: ModuleData) -> void:
	RunState.grant_module(module)
	for child in reward_options_container.get_children():
		child.queue_free()
	reward_header.text = "Reward granted: %s" % module.display_name
	restart_button.disabled = false
	exit_button.disabled = false
