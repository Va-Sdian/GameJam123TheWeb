extends Node2D

func _ready():
	randomize()
	
#func play(ShootSounds = null):
#	if ShootSounds:
#		print('Sound!')
#		get_node(ShootSounds).play()
#	else:
#		print('Else Sound!')
#		var c = randi()%get_child_count()
#		get_child(c).play()

func play():
	get_child(0).play()
