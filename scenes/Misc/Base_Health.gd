extends Node2D

signal base_damage(damage)

@onready var player = $BaseCollision
@onready var DeathTimer = $DeathTimer
@onready var damageParticle = $damageParticle
@onready var DeathParticles = $DeathParticles
#const max_health: int = 1000
const min_health: int = 5
@onready var health: int = min_health + Global.base_health_mult

@onready var damage_sound = $DamageSound

#Global.base_health_now = health
var state = null

func _ready():
	GlobalSignals.emit_signal("base_damage", health)
	#print("Base hp is = ", health)

func handle_hit(damage):
	damage_sound.play()
	damageParticle.emitting = true
	health = clamp(health - damage, 0.0, 1000.0)
	GlobalSignals.emit_signal("base_damage", health)
	if health == 0.0 and DeathTimer.time_left == 0:
		DeathTimer.start()
#		$AnimationTree.set("parameters/Transition/current", 2)  #Вставить анимацию взрыва базы
		if DeathTimer.time_left != 0:
			DeathParticles.emitting = true
			GlobalSignals.emit_signal("game_over")


func _on_area_for_quarantined_body_entered(virus):
	if virus.has_method('stunned'):
		virus.in_base_capture_radius = true
	if virus.state == 5:
		virus.set_state(4)


func _on_area_for_quarantined_body_exited(virus):
	if virus.has_method('stunned'):
		virus.in_base_capture_radius = false
