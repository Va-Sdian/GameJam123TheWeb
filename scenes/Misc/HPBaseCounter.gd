extends NinePatchRect

@onready var hp_label = $HP_Label

func _ready():
	hp_label.text = str(Global.base_health_mult + 5)


func base_damage(health) -> void:
	#print("base_damage recieved! Health = ", health)
	hp_label.text = str(health)
