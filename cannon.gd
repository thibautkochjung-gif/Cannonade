extends Node2D

@export var cannonball_scene : PackedScene
@export var broadside : Node2D
@export var cooldown_time_avg = 8.0
@export var cooldown_time_variance = 2

var player : CharacterBody2D
var ready_to_fire = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent().get_parent()
	$CooldownTimer.wait_time = randf_range(cooldown_time_avg - cooldown_time_variance, cooldown_time_avg + cooldown_time_variance)

func cannon_fire():
	
	if not ready_to_fire:
		return
	
	var cannonball = cannonball_scene.instantiate()
	cannonball.global_position = global_position
	cannonball.player = player
	cannonball.broadside = broadside
	get_tree().root.add_child(cannonball)
	
	ready_to_fire = false
	$CooldownTimer.start()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cooldown_timer_timeout() -> void:
	print ("finished timer")
	ready_to_fire = true
	$CooldownTimer.wait_time = randf_range(cooldown_time_avg - cooldown_time_variance, cooldown_time_avg + cooldown_time_variance)
