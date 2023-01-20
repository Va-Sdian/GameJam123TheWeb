extends KinematicBody2D
class_name Player

signal player_damage(damage)
signal game_over()

export (PackedScene) var Bullet

const MAX_SPEED = 120
const ACCELEARTION = 800
const FRICTION = 10000

var health: int = 100
var velocity = Vector2.ZERO

onready var player = $PlayerCollision
onready var DeathTimer = $DeathTimer
onready var weapon = $AntiVirus/Weapon


func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	input_vector = input_vector.normalized()
	if Input.is_action_pressed("ui_accept"):
		print(DeathTimer.time_left)
		handle_hit(1)
#		print("Die!")
	
	if Input.is_action_pressed("shoot"):
		weapon.shoot(self) 
	if Input.is_action_pressed("capture"):
		weapon.capture()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELEARTION * delta)
		$AnimationTree.set("parameters/Transition/current", 1) 
		$Legs.rotation = velocity.angle()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		if health != 0:
			$AnimationTree.set("parameters/Transition/current", 0) 
#			animation.stop()
#		$Legs.frame = 0 #Прикольней же когда останавливается в движении
	
	var mouse_position = get_global_mouse_position()
	if mouse_position != player.global_position:
		$AntiVirus.look_at(mouse_position)
		$AntiVirus.rotation_degrees -= 90
	
	velocity = move_and_slide(velocity)


func handle_hit(damage):
	GlobalSignals.emit_signal("player_damage", health)
	health = clamp(health - 1, 0.0, 100.0)
	if health == 0.0 and DeathTimer.time_left == 0:
		DeathTimer.start()
		$AnimationTree.set("parameters/Transition/current", 2) 
		if DeathTimer.time_left != 0:
			GlobalSignals.emit_signal("game_over")
