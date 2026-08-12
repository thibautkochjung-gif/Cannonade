class_name AmmoData
extends Resource

@export_group("Damage")
@export var hull_damage: float = 0.0
@export var sail_damage: float = 0.0
@export var stun_trauma: float = 0.0
@export var burn_amount: float = 0.0
@export var explosion_chance: float = 0.01

@export_group("Projectile")
@export var amount: float = 6.0
@export var velocity_variance: float = 0.0
@export var drag: float = 0.0
@export var spread_angle: float = 0.0
@export var projectile_scale: float = 1.0

@export_group("Visuals")
@export_range(0.0, 1.0) var splash_chance: float = 1.0
@export var water_splash_size: float = 1.0
@export var water_splash_particle_multiplier: float = 1.0
@export var water_splash_particle_scale: float = 1
@export var damage_fx_trigger_chance: float = 1.0

@export_group("Special")
@export var explosion_vulnerability: float = 0.0
@export var display_name: String

@export_group("Reload")
@export var reload_speed_multiplier: float = 1.0
