extends ColorRect

var a = 0.005
var old_color = 0

func _ready():
	GlobalSignals.connect("base_damage", get_base_damage)
	#print(color)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func get_base_damage(_health):
	old_color = color
	color += Color(0, 0, 0, a)
