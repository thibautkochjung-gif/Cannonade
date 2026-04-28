extends RigidBody2D

@export var ship : CharacterBody2D
@export var broadside : Node2D
@export var shot_strength_variance = 0.1
@export var despawn_timer : Timer

var default_despawn_time = 1.3
var despawn_time_variance = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var direction = broadside.global_transform.y
	var strength = broadside.shot_strength * randf_range(1-shot_strength_variance, 1+shot_strength_variance)
	apply_impulse( direction * strength + ship.velocity)
	despawn_timer.wait_time = randf_range(default_despawn_time - despawn_time_variance, default_despawn_time + despawn_time_variance)
	despawn_timer.start()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node) -> void:
	print("COLLISION")
	body.get_node("Health").take_damage(10)
	queue_free()
