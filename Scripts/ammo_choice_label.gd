extends Label
class_name AmmoChoiceLabel

func _ready() -> void:
	text = "Ammunition: " + "Round Shot" ## WILL NEED TO BE CHANGED IF DEFAULT SHOT CHANGES

func update_ammo_choice_label(new_ammo: AmmoData) -> void:
	text = "Ammunition: " + new_ammo.display_name
