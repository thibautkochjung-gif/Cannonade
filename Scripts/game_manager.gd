extends Node
@export var death_screen_scene: PackedScene
@export var victory_screen_scene: PackedScene
@export var game_scene: PackedScene
@export var main_menu: PackedScene
@export var hub_scene: PackedScene

var start_time: int
var death_time_msec: int
var player: CharacterBody2D
var hud: HUD
var world_root: Node


func on_player_ready(spawned_player: CharacterBody2D) -> void:
	player = spawned_player
	hud = get_tree().get_first_node_in_group("hud")
	hud.connect_to_player(player)
	var ammo_reminder_popup = get_tree().get_first_node_in_group("ammo_reminder_popup")
	if ammo_reminder_popup:
		ammo_reminder_popup.connect_to_player(player)


func trigger_victory() -> void:
	var victory_screen = victory_screen_scene.instantiate()
	get_tree().current_scene.add_child(victory_screen)


func _process(delta: float) -> void:
	if hud and player:
		var elapsed_seconds := int((Time.get_ticks_msec() - start_time) / 1000.0)
		hud.survival_timer_label.update_time(elapsed_seconds)


func format_time(total_seconds: int) -> String:
	@warning_ignore("integer_division")
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	return "%d:%02d" % [minutes, seconds]

func player_death() -> void:
	death_time_msec = Time.get_ticks_msec()
	var total_seconds = int((death_time_msec - start_time) / 1000.0)
	var time_survived_text = "You survived " + format_time(total_seconds)
	var death_screen = death_screen_scene.instantiate()
	get_tree().current_scene.add_child(death_screen)
	death_screen.set_survival_text(time_survived_text)


func start_contract(contract: ContractData) -> void:
	RunState.active_contract = contract
	get_tree().change_scene_to_packed(game_scene)
	start_time = Time.get_ticks_msec()


func goto_hub() -> void:
	get_tree().change_scene_to_packed(hub_scene)


func goto_main_menu() -> void:
	get_tree().change_scene_to_packed(main_menu)


func quit_game() -> void:
	get_tree().quit()
