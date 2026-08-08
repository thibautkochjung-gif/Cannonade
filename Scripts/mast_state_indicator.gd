extends HBoxContainer
class_name MastStateIndicator

const SELECTED_COLOR := Color.WHITE
const DIM_COLOR := Color(0.4, 0.4, 0.4)

@onready var mast_rects: Array[ColorRect] = [$"MastState4", $"MastState3", $"MastState2", $"MastState1"]

func _ready() -> void:
	for rect in mast_rects:
		rect.color = DIM_COLOR

func update_mast_state(new_state: int) -> void:
	for i in mast_rects.size():
		mast_rects[i].color = SELECTED_COLOR if i == new_state else DIM_COLOR
