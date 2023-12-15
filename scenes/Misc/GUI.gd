extends Control

@onready var gameover = $GameOver
@onready var gmtimer = $GameOver/GameOverTimer
@onready var gosound = $GameOver/DeathSound
@onready var gomusic = $GameOver/DeathMusic
@onready var level_timer_patch_rect = $VBoxContainer/HUD/Level_Timer
signal timeout

func _ready():
	gmtimer.connect('timeout', _on_game_over_timer_timeout)



func game_over():
	#print("gmtimer.start")
	gmtimer.start()
	gosound.play()

func start_level_timer(_wait_time):
	#print(_wait_time, "wait time передаваемый функции")
	#print (level_timer_patch_rect.timer.wait_time, "веит тайм таймера до нового назначения и запуска")
	level_timer_patch_rect.timer.wait_time = _wait_time
	#print (level_timer_patch_rect.timer.wait_time, "веит тайм после назначения")
	level_timer_patch_rect.timer.start()


func _on_level_completed_timer_timeout():
	get_tree().paused = not get_tree().paused
	$LevelCompleted.visible = true
	

func _on_game_over_timer_timeout():
	#print("GameOverTimer_timeout")
	gmtimer.stop()
	gomusic.play()
	#var new_pause_state = not get_tree().paused
	get_tree().paused = not get_tree().paused
	gameover.visible = true
