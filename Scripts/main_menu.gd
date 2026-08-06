extends Control

@export var new_game_button: Button
@export var exit_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game_button.pressed.connect(GameManagerScene.start_new_game)
	exit_button.pressed.connect(GameManagerScene.quit_game)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
