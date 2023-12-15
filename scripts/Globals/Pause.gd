extends Control

func _input(event):
	if event.is_action_pressed("pause"):
		var new_pause_state = not get_tree().paused
		get_tree().paused = not get_tree().paused
		visible = new_pause_state

#var is_paused = false : set = set_is_paused
#
#func _unhandled_input(event):
#	if event.is_action_pressed("pause"):
#		self.is_paused = !is_paused
#
#func set_is_paused(value):
#	is_paused = value
#	get_tree().paused = is_paused
#	visible = is_paused
#
