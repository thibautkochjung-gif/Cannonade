class_name AmmoData
extends Resource

@export_group("Damage")
@export var hull_damage: float = 0.0
@export var sail_damage: float = 0.0
@export var stun_trauma: float = 0.0
@export var burn_amount: float = 0.0

@export_group("Projectile")
@export var amount: float = 6
@export var drag: float = 0.0
@export var water_splash_size: float = 1.0
@export var spread_angle: float = 0.0

@export_group("Special")
@export var explosion_vulnerability: float = 0.0

@export_group("Reload")
@export var reload_speed_multiplier: float = 1.0
