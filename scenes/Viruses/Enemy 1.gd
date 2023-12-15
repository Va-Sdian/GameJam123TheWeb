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
#onready var globalPosition = self.global_position

signal enemyStunned(target, enemy)

@export var receives_knockback: bool: bool = true
@export var knockback_modifier: float: float = 2
#onready var knockback
#onready var knockback_dir

var motion = Vector2()
@onready var velocity = Vector2.ZERO
@onready var state = SPAWNING
@onready var was_state = ALIVE
@onready var attackCD = $AttackCD
@onready var StunT = $StunTimer
@onready var weapon = $Weapon
@onready var health = 10
@onready var direction_to_base = Vector2.ZERO
@onready var Dspring = $DSpringJoint

#onready var SpringJoint = $DSpringJoint
#onready var jointLine = $DSpringJoint/jointLine

#onready var player = null

var target : set = set_target

#var distance_to_player = global_position.distance_to(Game.player.global_position)
#var vector_to_player = (Game.player.global_position - global_position).normalized()

enum {
	SPAWNING
	ALIVE
	ATTACK
	DEAD
	QUARANTINED
	STUN
}

func _process(delta: float) -> void:
	#if target != null:
	#	print(target.p_g_p)
		#print(target.health)
	#print(target)
	#print(get_path_to(target))
	pass

func set_target(value):
	target=value


func _physics_process(delta):
	#knockback = knockback.move_toward(Vector2.UP, 2000 * delta)
	set_velocity(knockback)
	move_and_slide()
	#knockback = velocity
#	if target != null:
#		NetJointLine(target)
	
	#if knockback == true:
	#	motion.x = 500 * knockback_dir
	#	knockback = false
	
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
			set_velocity(velocity)
			move_and_slide()
			velocity = velocity

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
			animationPlayer.play("stunned")
			direction_to_base = Vector2.ZERO
			#knockback
			if StunT.time_left == 0:
				state = was_state 


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
	#velocity = velocity




func _on_Check_timeout():
	if state == DEAD:
		queue_free()
	elif state == SPAWNING:
		state = ALIVE
	elif state == ATTACK:
		state = ALIVE
	elif state == STUN:
		pass


func _on_AttackCD_timeout():
		state = ATTACK

func stunned(damage):
	#print("stunned")
	was_state = state
	StunT.start()
	health -= damage
	if health == 0:
		state = DEAD
	state = STUN
	connect("enemyStunned",Callable(Dspring,"connect_bodies"))
	emit_signal("enemyStunned", self, target)
	
#	NetJoint(target)
	

#func NetJoint(target):
#	SpringJoint.connect_bodies(target, self)
	#print(target)
	#print(get_path_to(target))
	#var nodePath: NodePath = "."
	#SpringJoint.set_node_a(get_path_to(self))
	#SpringJoint.set_node_b(get_path_to(target)) #Игрок, и если игрок уже назначен, то второй враг
	
	
#func NetJointLine(target):
#	jointLine.points = []
#	jointLine.add_point(Vector2.ZERO)
#	#print(self.global_position)
#	jointLine.add_point(target.global_position)
#	#print(target.global_position)


func handle_hit(damage: int):
	health -= damage
	if health == 0:
		state = DEAD

func receive_knockback(damage_source_pos: Vector2, received_damage: int):
	if receives_knockback:
		var knockback_direction = damage_source_pos.direction_to(self.global_position)
		var knockback_strength = received_damage * knockback_modifier
		var knockback = knockback_direction * knockback_strength

		global_position += knockback


func _on_BaseDetection_body_entered(body): #Атакует игрока
	#if body.has_method("get_bounce"):
	#	base = body
		#print(base.global_position)
	#body=base #Что это делает?
	#base=target
	pass


func _on_AttackRadius_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body == base:
		state = ATTACK
		velocity = Vector2.ZERO


func _on_DeathTimer_timeout():
	emit_signal("tree_exiting")
	queue_free()


func _on_AttackFollowRadius_area_shape_exited(area_rid, body, area_shape_index, local_shape_index):
	#print(body)
	if body == target:
		print("exited")
#	if state == ATTACK:
#		state = ALIVE

