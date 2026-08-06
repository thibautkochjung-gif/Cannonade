extends CanvasLayer

@export var restart_button: Button
@export var exit_button: Button
@export var survival_label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	restart_button.pressed.connect(GameManagerScene.start_new_game)
	exit_button.pressed.connect(GameManagerScene.goto_main_menu)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_survival_text(text: String) -> void:
	survival_label.text = text
