extends TextureProgress
#var health = 100

func _ready():
	value = 100

#func set_percent_value_int(health):
#	value = health

func player_damage_recieved(health) -> void:
	value = int(health)
