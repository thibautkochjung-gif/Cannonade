extends Control

@export var title_label: Label
@export var description_label: Label
@export var main_objective_label: Label
@export var secondary_objectives_list: VBoxContainer
@export var rewards_list: VBoxContainer
@export var back_button: Button
@export var begin_button: Button

var _contract: ContractData


func _ready() -> void:
	visible = false
	back_button.pressed.connect(_on_back_pressed)
	begin_button.pressed.connect(_on_begin_pressed)


func open(contract: ContractData) -> void:
	_contract = contract
	title_label.text = contract.display_name
	description_label.text = contract.long_description
	main_objective_label.text = contract.objective.display_name if contract.objective else "(none)"
	_populate_list(secondary_objectives_list, contract.secondary_objectives)
	_populate_list(rewards_list, contract.reward_modules)
	visible = true


func _populate_list(container: VBoxContainer, items: Array) -> void:
	for child in container.get_children():
		child.queue_free()
	if items.is_empty():
		var empty_label := Label.new()
		empty_label.text = "None"
		container.add_child(empty_label)
		return
	for item in items:
		var label := Label.new()
		label.text = "- %s" % item.display_name
		container.add_child(label)


func _on_back_pressed() -> void:
	visible = false


func _on_begin_pressed() -> void:
	visible = false
	GameManagerScene.start_contract(_contract)
