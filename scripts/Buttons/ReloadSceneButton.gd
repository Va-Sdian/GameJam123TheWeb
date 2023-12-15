extends TextureButton

@export var reference_path = ""
@export var start_focused: bool = false

func _ready():
	if(start_focused):
		grab_focus()
		
	connect("mouse_entered",Callable(self,"_on_Button_mouse_entered"))
	connect("pressed",Callable(self,"_on_Button_Pressed"))

func _on_Button_mouse_entered():
	grab_focus()

func _on_Button_Pressed() -> void:
	Global.score = Global.previous_score
	get_tree().reload_current_scene()
	get_tree().paused = false
