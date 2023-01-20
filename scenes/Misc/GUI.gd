extends Control

onready var gameover = $GameOver
onready var gmtimer = $GameOver/GameOverTimer
onready var gosound = $GameOver/DeathSound
onready var gomusic = $GameOver/DeathMusic

func game_over():
	gmtimer.start()
	gosound.play()

func _on_GameOverTimer_timeout():
	gmtimer.stop()
	gomusic.play()
	var new_pause_state = not get_tree().paused
	get_tree().paused = not get_tree().paused
	gameover.visible = true
