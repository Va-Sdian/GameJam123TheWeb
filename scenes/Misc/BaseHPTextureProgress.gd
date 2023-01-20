extends TextureProgress

func _ready():
	value = 100


func base_damage(health) -> void:
	value = int(health)
