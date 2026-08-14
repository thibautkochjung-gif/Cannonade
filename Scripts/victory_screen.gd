extends CanvasLayer

@export var restart_button: Button
@export var exit_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	restart_button.pressed.connect(GameManagerScene.start_new_game)
	exit_button.pressed.connect(GameManagerScene.goto_main_menu)
	
