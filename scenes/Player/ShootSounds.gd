extends Node2D

func _ready():
	randomize()
	
func play(ShootSounds = null):
	if ShootSounds:
		get_node(ShootSounds).play()
	else:
		var c = randi()%get_child_count()
		get_child(c).play()
