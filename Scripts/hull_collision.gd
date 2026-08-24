extends Area2D

@export var collision_damage: CollisionDamage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	
	if !body.is_in_group("ship") && !body.is_in_group("terrain"):
		return
	
	if body.is_in_group("terrain"):
		print("collision detected with terrain")
		collision_damage.on_terrain_collision()
		if collision_damage.ship.has_method("zero_velocity"):
			collision_damage.ship.zero_velocity()
	
	if body.is_in_group("ship"):
		collision_damage.on_ship_collision(body)
		
		if collision_damage.ship.has_method("zero_velocity"):
			collision_damage.ship.zero_velocity()
		if body.has_method("zero_velocity"):
			body.zero_velocity()
