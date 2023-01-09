extends KinematicBody2D

export var ACCELERATION = 400
export var MAX_SPEED = 110
export var FRICTION = 700

onready var base = null
onready var Global = "/root/scripts/Globals/Global.gd"
onready var checkTimer = $Check
onready var animationPlayer = $AnimationPlayer
onready var enemy = $EnemyCollision
onready var direction = Vector2.RIGHT
onready var direction_to_base = Vector2.ZERO
onready var knockback = Vector2.ZERO
onready var velocity = Vector2.ZERO
onready var state = SPAWNING
onready var attackCD = $AttackCD
onready var weapon = $Weapon

enum {
	SPAWNING
	ALIVE
	ATTACK
	DEAD
	QUARANTINED
}


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 2000 * delta)
	knockback = move_and_slide(knockback)
	match state:
		SPAWNING:
			if checkTimer.time_left == 0:
				checkTimer.start()
			state = ALIVE
		ALIVE:
			animationPlayer.play("Walk")
			if base != null:
				direction_to_base = position.direction_to(base.global_position)
			velocity = velocity.move_toward(direction_to_base * MAX_SPEED, ACCELERATION * delta)
			look_at(direction_to_base)
		ATTACK:
			weapon.shoot()
			if checkTimer.time_left == 0:
				checkTimer.start()
			if attackCD.time_left == 0:
				attackCD.start()
				$EnemyShoot.play()
		DEAD:
			queue_free()
		QUARANTINED:
			Global.score += 1
			queue_free()
		_:
			print ("Exception in states found")
	
	velocity = move_and_slide(velocity)
	


func _on_Check_timeout():
	if state == DEAD:
		queue_free()
	elif state == SPAWNING:
		state = ALIVE
	elif state == ATTACK:
		state = ALIVE


func _on_AttackCD_timeout():
		state = ATTACK


func handle_hit():
	state = DEAD


func _on_BaseDetection_body_entered(body):
	if body.has_method("get_bounce"):
		base = body


func _on_AttackRadius_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body == base:
		state = ATTACK
		velocity = Vector2.ZERO
