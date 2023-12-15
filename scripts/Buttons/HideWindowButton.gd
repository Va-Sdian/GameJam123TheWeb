extends TextureButton

@export var start_focused: bool = false

func _ready():
	if(start_focused):
		grab_focus()
	connect("mouse_entered",Callable(self,"_on_Button_mouse_entered"))
	connect("pressed",Callable(self,"_on_Button_Pressed"))

func _on_Button_Pressed() -> void:
	get_window().mode = Window.MODE_MINIMIZED if (true) else Window.MODE_WINDOWED

func _on_Button_mouse_entered():
	grab_focus()
