extends CanvasLayer
class_name HUD

@export var health_indicator: Control
@export var sail_condition_indicator: Control
@export var mast_state_indicator: HBoxContainer
@export var mast_state_icons: TextureRect
@export var right_broadside_indicator: TextureProgressBar
@export var left_broadside_indicator: TextureProgressBar
@export var survival_timer_label: SurvivalTimerLabel
@export var ammo_choice_icon: TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func connect_to_player(player: Node) -> void:
	player.health.health_changed.connect(health_indicator.update_health)
	player.ammo_manager.ammo_changed.connect(ammo_choice_icon.update_ammo_choice_icon)
	player.mast_state_changed.connect(mast_state_indicator.update_mast_state)
	player.mast_state_changed.connect(mast_state_icons.update_mast_state)
	player.right_broadside.reload_percentage_changed.connect(right_broadside_indicator.update_reload_indicator)
	player.left_broadside.reload_percentage_changed.connect(left_broadside_indicator.update_reload_indicator)
	player.sail_condition.sail_condition_changed.connect(sail_condition_indicator.update_sail_condition)
