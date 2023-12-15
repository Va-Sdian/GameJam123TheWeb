extends Camera2D

const DEAD_ZONE = 160
const change_camera_lenght_move = 0.2

func _input(event: InputEvent) -> void:
#	print("event.position:", event.position) #Координаты мыши
#	print(get_viewport().size) #Размер окна
	if event is InputEventMouseMotion:
		var _target = event.position - get_viewport().size * 0.5
		if _target.length() < DEAD_ZONE:
			self.position = Vector2(0,0)
		else:
			self.position = _target.normalized() * (_target.length() - DEAD_ZONE) * change_camera_lenght_move
			#print(_target.length()) #Низкое число когда мышь по центур экрана, и увеличивается к краям
			#print(_target.normalized()) #Координаты мыши х,у с значениями от 0 до 1

