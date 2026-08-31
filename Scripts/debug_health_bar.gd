class_name DebugHealthBar
extends Node2D

const WIDTH := 40.0
const HEIGHT := 5.0
const OFFSET := Vector2(0, -40)  # tweak to sit above your ship sprites

var _current_health: float = 1.0
var _max_health: float = 1.0

func _ready() -> void:
	add_to_group("debug_health_bar")

func setup(health: Health) -> void:
	_max_health = health.max_health
	_current_health = health.current_health
	health.health_changed.connect(_on_health_changed)
	queue_redraw()

func _on_health_changed(_amount, max_health, current_health, _hit_direction, _source, _fx_trigger_chance) -> void:
	_max_health = max_health
	_current_health = current_health
	queue_redraw()

func _process(_delta: float) -> void:
	var parent := get_parent() as Node2D
	if parent:
		global_position = parent.global_position + OFFSET
	global_rotation = 0.0  # stay upright regardless of ship rotation

func _draw() -> void:
	var ratio: float = clampf(_current_health / _max_health, 0.0, 1.0)
	draw_rect(Rect2(-WIDTH / 2, 0, WIDTH, HEIGHT), Color.BLACK)
	draw_rect(Rect2(-WIDTH / 2, 0, WIDTH * ratio, HEIGHT), Color.RED)
