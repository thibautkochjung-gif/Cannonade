extends Node

var player: CharacterBody2D

@export var minimum_distance: int
@export var maximum_distance: int
@export var enemy_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_enemy_at_random_location() -> void:
	var spawn_distance = randf_range(minimum_distance, maximum_distance)
	var spawn_angle = randf_range(0, TAU)
	var spawn_vector = Vector2(spawn_distance, 0).rotated(spawn_angle)
	var enemy = enemy_scene.instantiate()
	
	get_parent().add_child(enemy)
	enemy.position = spawn_vector + player.global_position
	enemy.look_at(player.global_position)
	print("Spawned enemy")
	
	pass


func _on_timer_timeout() -> void:
	spawn_enemy_at_random_location()
