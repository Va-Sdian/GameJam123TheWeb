extends TextureButton

@export var start_focused: bool = false

func _ready():
	if(start_focused):
		grab_focus()
		#print("start_focused") #Не пишет
		


func _on_Button_mouse_entered(): #Работает
	grab_focus()


func _pressed() -> void:
	#print("next level button pressed")
	Global.previous_score = Global.score #Сохраняет очки
	if Global.current_level == "FirstLevel":
		get_tree().change_scene_to_file("res://scenes/Menus/SecondLevel.tscn")
		get_tree().paused = false
	elif Global.current_level == "SecondLevel":
		get_tree().change_scene_to_file("res://scenes/Menus/ThirdLevel.tscn")
		get_tree().paused = false
	elif Global.current_level == "ThirdLevel":
		get_tree().change_scene_to_file("res://scenes/Menus/you_win.tscn")
		get_tree().paused = false
