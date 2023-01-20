extends Label

func player_damage_recieved(health) -> void:
	self.text = str(health)

