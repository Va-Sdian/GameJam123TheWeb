extends Node

#Зачем это нужно?
signal bullet_fired(bullet, position, direction)
signal bulletCapture_fired(bullet, position, direction, LCE, wasLCE)
signal player_damage(health)
signal base_damage(health)
signal game_over()
signal changePiC(PiC) #Player is Connected
signal changeLCE(enemy) #Last enemy connected
signal changewasLCE(enemy)
signal level_completed(current_level)
signal start_level_timer(wait_time)
signal next_level(current_level)

func _ready():
	#emit_signal("base_damage", health)
	pass
