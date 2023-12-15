extends TextureButton

@export var reference_path = ""
@export var start_focused: bool = false

func _ready():
	if(start_focused):
		grab_focus()
		#print("start_focused") #Не пишет
		
	#connect("mouse_entered",Callable(self,"_on_Button_mouse_entered"))
	#connect("pressed",Callable(self,"_on_Button_Pressed"))

func _on_Button_mouse_entered(): #Работает
	grab_focus()


#func _on_Button_Pressed() -> void: 
#	if(reference_path != ""):
#		get_tree().change_scene_to_file(reference_path)
#		get_tree().paused = false
#	else:
#		get_tree().quit()


func _pressed() -> void:
	Global.previous_score = Global.score
	if(reference_path != ""):
		get_tree().change_scene_to_file(reference_path)
		get_tree().paused = false
	else:
		get_tree().quit()
