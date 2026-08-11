extends Node2D

@export var burn_fx_scene : PackedScene
@export var status_effects : StatusEffects
@export var burn_trigger_particle_chance: float = 0.2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	status_effects.burn_applied.connect(_on_burn_applied)
	status_effects.burn_stopped.connect(_on_burn_stopped)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for burn_particle_fx in get_children().filter(
		func(child): return child.is_in_group("burn_particle_parent_node")):
			burn_particle_fx.global_rotation = 0.0


func _on_burn_applied(local_position: Vector2) -> void:
	print("Burn applied")
	
	if randf() < burn_trigger_particle_chance :
		var burn_fx_inst = burn_fx_scene.instantiate()
		add_child(burn_fx_inst)
		burn_fx_inst.position = local_position

		for burn_particle_parent_node in get_children().filter(
			func(child): return child.is_in_group("burn_particle_parent_node")):
			for flame_flow in burn_particle_parent_node.get_children().filter(
				func(child): return child.is_in_group("flame_flow")):
				flame_flow.restart()


func _on_burn_stopped() -> void:
	print("Burn stopped")
	
	for burn_particle_parent_node in get_children().filter(
		func(child): return child.is_in_group("burn_particle_parent_node")):
		for flame_flow in burn_particle_parent_node.get_children().filter(
			func(child): return child.is_in_group("flame_flow")):
			flame_flow.emitting = false
