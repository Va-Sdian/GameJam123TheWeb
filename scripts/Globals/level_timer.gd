extends NinePatchRect
@onready var timer = $Timer
@onready var timer_numbers = $Timer_Numbers

func _ready():
	timer.connect('timeout', _on_level_timer_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	timer_numbers.text = str(int(timer.time_left))

func start_level_timer(wait_time):
	timer.wait_time = wait_time
	timer.start()

func _on_level_timer_timeout():
	GlobalSignals.emit_signal("level_completed") 
	#print("signal level_completed on level_timer emmited")
	#Global.level_finished()
