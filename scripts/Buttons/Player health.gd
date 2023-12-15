extends TextureButton

@export var start_focused: bool = false

func _ready():
	if(start_focused):
		grab_focus()

func _on_Button_mouse_entered(): #Работает
	grab_focus()

func _pressed() -> void:
	#print(" button pressed")
	if Global.score > 0:
		Global.player_health_bonus += 1
		Global.score -= 1
