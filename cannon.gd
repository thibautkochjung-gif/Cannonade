extends Node2D

@export var cannonball_scene : PackedScene
@export var cooldown_time_avg = 8.0
@export var cooldown_time_variance = 2

var ship : Node2D
var ready_to_fire = true

signal cannon_ready

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Broadside ready, children: ", get_children().size())
	ship = get_parent().get_parent()
	$CooldownTimer.wait_time = randf_range(cooldown_time_avg - cooldown_time_variance, cooldown_time_avg + cooldown_time_variance)

var cannon_ready_count: int:
	set(value):
		print("cannon_ready_count changed to: ", value)
		cannon_ready_count = value

func cannon_fire(broadside_firing):
	
	if not ready_to_fire:
		return
	
	var cannonball = cannonball_scene.instantiate()
	cannonball.global_position = global_position
	cannonball.ship = ship
	cannonball.broadside = broadside_firing
	get_tree().root.add_child(cannonball)
	
	ready_to_fire = false
	$CooldownTimer.start()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cooldown_timer_timeout() -> void:
	ready_to_fire = true
	$CooldownTimer.wait_time = randf_range(cooldown_time_avg - cooldown_time_variance, cooldown_time_avg + cooldown_time_variance)
	cannon_ready.emit()
