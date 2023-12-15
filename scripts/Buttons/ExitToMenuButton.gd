extends TextureButton

@export var start_focused: bool = false

func _ready():
	if(start_focused):
		grab_focus()
		#print("start_focused") #Не пишет


func _on_Button_mouse_entered(): #Работает
	grab_focus()


func _pressed() -> void:
	Global.score = 0
	Global.current_level = "MainMenu"
	get_tree().change_scene_to_file("res://scenes/Menus/MainMenu.tscn")
	get_tree().paused = false
