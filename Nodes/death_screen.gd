extends CanvasLayer

@export var restart_button: Button
@export var exit_button: Button
@export var survival_label: Label

func _ready() -> void:
	restart_button.pressed.connect(func(): GameManagerScene.start_contract(RunState.active_contract))
	exit_button.pressed.connect(GameManagerScene.goto_hub)

func set_survival_text(text: String) -> void:
	survival_label.text = text
