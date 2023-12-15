extends CharacterBody2D

@export var ACCELERATION = 400
@export var MAX_SPEED = 110
@export var FRICTION = 700

@onready var base = null
@onready var Global = "/root/scripts/Globals/Global.gd"
@onready var checkTimer = $Check
@onready var DeathTimer = $DeathTimer
@onready var animationPlayer = $AnimationPlayer
@onready var enemy = $EnemyCollision
@onready var direction = Vector2.RIGHT
@onready var knockback = Vector2.ZERO
@onready var velocity = Vector2.ZERO
@onready var state = SPAWNING
@onready var attackCD = $AttackCD
@onready var weapon = $Weapon
@onready var health = 2
@onready var direction_to_base = Vector2.ZERO
@onready var direction_to_player = Vector2.ZERO


enum {
	SPAWNING
	ALIVE
	ATTACK
	DEAD
	QUARANTINED
	STUN
}


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 2000 * delta)
	set_velocity(knockback)
	move_and_slide()
	knockback = velocity
	match state:
		SPAWNING:
			if checkTimer.time_left == 0:
				checkTimer.start()
			state = ALIVE
		ALIVE:
			animationPlayer.play("Walk")
			if base != null:
				direction_to_base = position.direction_to(base.global_position)
				look_at(base.global_position) 
				#direction_to_base = base.global_position #Работает, но враг движется намного быстрее
			velocity = velocity.move_toward(direction_to_base * MAX_SPEED, ACCELERATION * delta)
			
		
		ATTACK:
			weapon.shoot(self)
			look_at(base.global_position) 
			if checkTimer.time_left == 0:
				checkTimer.start()
			if attackCD.time_left == 0:
				attackCD.start()
				$EnemyShootSounds.play()
		STUN:
			attackCD.stop()
			#animationPlayer.play("Walk") #Анимация стана

		DEAD:
			DeathTimer.start()
			attackCD.stop()
			animationPlayer.play("death")
#			if DeathTimer.time_left == 0: 
#				queue_free()
		QUARANTINED:
			Global.score += 1
			queue_free()
		_:
			print ("Exception in states found")
	
	set_velocity(velocity)
	move_and_slide()
	velocity = velocity
	


func _on_Check_timeout():
	if state == DEAD:
		queue_free()
	elif state == SPAWNING:
		state = ALIVE
	elif state == ATTACK:
		state = ALIVE


func _on_AttackCD_timeout():
		state = ATTACK

func stunned(damage):
	print("stunned")
	health -= damage
	if health == 0:
		state = DEAD
	state = STUN

func handle_hit(damage):
	health -= damage
	if health == 0:
		state = DEAD


func _on_BaseDetection_body_entered(body):
	if body.has_method("get_bounce"):
		base = body
		#print(base.global_position)
		
		


func _on_AttackRadius_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body == base:
		state = ATTACK
		velocity = Vector2.ZERO


func _on_DeathTimer_timeout():
	queue_free()
