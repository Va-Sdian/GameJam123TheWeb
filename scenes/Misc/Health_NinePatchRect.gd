extends NinePatchRect


class_name Health

@onready var hp_label = $HP_Label
#export (int) var health = 2 : get = get_health, set = set_health
#var health : get = get_health, set = set_health
#
#func set_health(new_health: int):
#	health = clamp(new_health, 0, health)
#	$HP_Label.text = health
#	print(health)
#
#func get_health():
#	return health

func player_damage_recieved(health) -> void:
	hp_label.text = str(health)
