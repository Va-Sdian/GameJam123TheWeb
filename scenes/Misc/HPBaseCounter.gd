extends NinePatchRect

onready var hp_label = $HP_Label

func base_damage(health) -> void:
	hp_label.text = str(health)
