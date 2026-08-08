extends Node

@export var death_screen_scene: PackedScene
@export var game_scene: PackedScene
@export var main_menu: PackedScene

var start_time: int
var death_time_msec: int
var player: CharacterBody2D
var hud: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func on_player_ready(spawned_player: CharacterBody2D) -> void:
	player = spawned_player
	hud = get_tree().get_first_node_in_group("hud")
	hud.connect_to_player(player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func player_death() -> void:
	death_time_msec = Time.get_ticks_msec()
	var total_seconds = int((death_time_msec-start_time) / 1000.0)
	@warning_ignore("integer_division")
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	var time_survived_text = "You survived %d minutes %d seconds" % [minutes, seconds]

	var death_screen = death_screen_scene.instantiate()
	get_tree().current_scene.add_child(death_screen)
	death_screen.set_survival_text(time_survived_text)


func start_new_game() -> void:
	get_tree().change_scene_to_packed(game_scene)
	start_time = Time.get_ticks_msec()
	
func goto_main_menu() -> void:
	get_tree().change_scene_to_packed(main_menu)

func quit_game() -> void:
	get_tree().quit()
