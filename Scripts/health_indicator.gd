extends Control
class_name HealthIndicator

@onready var fill_rect: ColorRect = $FillRect
@onready var ghost_fill_rect: ColorRect = $GhostFillRect
@onready var ghost_delay_timer: Timer = $GhostDelayTimer

@export var ghost_delay: float = 0.4
@export var ghost_tween_duration: float = 0.4

var full_width: float
var pending_percent: float
var ghost_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	full_width = fill_rect.size.x
	ghost_delay_timer.wait_time = ghost_delay
	ghost_delay_timer.one_shot = true
	ghost_delay_timer.timeout.connect(_on_ghost_delay_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_health(amount, max_health, current_health, hit_direction, source) -> void:
	var percent_health_left: float = current_health / max_health
	fill_rect.size.x = fill_rect.get_parent().size.x * percent_health_left
	
	# Ghost bar: cancel any in-progress catch-up, hold at its current
	# size, and restart the delay before catching up to the new value.
	if ghost_tween:
		ghost_tween.kill()

	pending_percent = percent_health_left
	ghost_delay_timer.start()


func _on_ghost_delay_timeout() -> void:
	ghost_tween = create_tween()
	ghost_tween.tween_property(
		ghost_fill_rect, "size:x", full_width * pending_percent, ghost_tween_duration
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
