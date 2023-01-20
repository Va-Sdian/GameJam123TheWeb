extends Node2D

signal base_damage(damage)

onready var player = $BaseCollision
onready var DeathTimer = $DeathTimer
var health: int = 100

func handle_hit(damage):
	GlobalSignals.emit_signal("base_damage", health)
	health = clamp(health - 1, 0.0, 100.0)
	if health == 0.0 and DeathTimer.time_left == 0:
		DeathTimer.start()
#		$AnimationTree.set("parameters/Transition/current", 2)  #Вставить анимацию взрыва базы
		if DeathTimer.time_left != 0:
			GlobalSignals.emit_signal("game_over")
