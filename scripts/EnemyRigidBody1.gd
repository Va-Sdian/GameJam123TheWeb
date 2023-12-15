extends RigidBody2D

@export var ACCELERATION = 200
@export var MAX_SPEED = 70 #110 Скорость игрока
@export var FRICTION = 700
@onready var outOfTiLeMapFriction = 45


@onready var base = null
@onready var player = null
#onready var Global = "/root/scripts/Globals/Global.gd"
@onready var checkTimer = $Check
@onready var DeathTimer = $DeathTimer
@onready var animationPlayer = $AnimationPlayer
@onready var enemy = $EnemyCollision
@onready var direction = Vector2.RIGHT
@onready var damageParticles = $damageParticles
@onready var deathParticles = $deathParticles
@onready var stunParticles = $stunParticles
@onready var aliveAfterDeathParticles = $aliveAfterDeathParticles
@onready var deathCounter = 0

signal enemyStunned(target, enemy)


@export var receives_knockback: bool = true
@export var knockback_modifier: float = 2
@onready var PiC: bool = false ##Player is Connected
@onready var LCE: Node2D ##Last connected Enemy
@onready var wasLCE: Node2D #Какой враг был присоединён до этого. Нужен для корректной работы цепочек
@onready var connectedEnemy: Node2D #Какой враг просоединён к LCE, обычно это self


@onready var connection_sound = $DSpringJoint/ConnectionSound
@onready var captured_sound = $captured_sound
@onready var death_sound = $death_sound
@onready var reincarnation_sound = $reincarnation_sound


#var motion = Vector2()
@onready var velocity = Vector2.ZERO
@onready var state = SPAWNING
@onready var was_state = ALIVE
@onready var in_base_capture_radius: bool = false

@onready var attackCD = $AttackCD
@onready var StunT = $StunTimer
@onready var weapon = $Weapon
@onready var health = 1
@onready var direction_to_base = Vector2.ZERO
@onready var direction_to_target = Vector2.ZERO
@onready var Dspring = $DSpringJoint
#@onready var player = find_child("../../Player", true) #Не пашет
var target : set = set_personal_target #текущая цель атаки. Сеттер не использую
@onready var targets =  get_tree().get_nodes_in_group("target")
#var player = null
var primal_target = null #Вот это первоначальная, приоритетная цель!

var Dspring_inst_preload = preload("res://scenes/Viruses/d_spring_joint.tscn")
var Dspring_instance: Node2D

@onready var wasLCE_Dspring_instance: Node2D
@onready var Child_Dspring_instance: Node2D

#Для Pathfinding
@onready var nav_agent := $NavigationAgent as NavigationAgent2D
@onready var Target_Detected: bool = false
@onready var RayCast_middle = $RayCast
@onready var RayCast_top = $RayCast2
@onready var RayCast_bottom = $RayCast3
@onready var RayCastEnemy_top: bool = false
@onready var RayCastEnemy_middle: bool = false
@onready var RayCastEnemy_bottom: bool = false


@onready var VOSN = $VisibleOnScreenNotifier



enum {
	SPAWNING,
	ALIVE, 
	ATTACK, #2
	DEAD,
	QUARANTINED, 
	STUN #5
	}

func set_state(_state):
	state = _state

func _process(_delta: float) -> void:
	#if target != null:
	#	print(target.p_g_p)
		#print(target.health)
	#print(target)
	#print(get_path_to(target))
	pass
	
func set_personal_target(value):
	target=value

func _ready():
	connect("enemyStunned",Callable(Dspring,"connect_bodies"))
	$AreaForDetection.connect('body_entered',Callable(self, '_on_Character_collided'))
	$AreaForDetection.connect('body_exited',Callable(self, '_body_exited_collider'))
	find_targer()
	health += Global.enemies_health_bonus

func find_targer():
	if base == null:
		var result = randf()
		#print("random result = ", result)
		if result <Global.player_agression:
			target = find_player()
			primal_target = target
		elif find_base() == null:
			target = find_player()
			primal_target = target
		else:
			target = find_base()
			primal_target = target


func find_player():
	for _target in targets:
		player = _target.get_node("../Player")
		return player
		
		
func find_base():
	for _target in targets:
		if str(_target).contains("Base"):
			base = _target.get_node("../Base")
			return base

func _physics_process(delta):
	var mouse_position = get_global_mouse_position() #На движение застанненных врагов к мыши
	
	#На патфайндинг
	#var pathfind_dir = to_local(nav_agent.get_next_path_position()).normalized() #Враги идут куда-то влево-вверх
	var pathfind_dir = nav_agent.get_next_path_position()
	
	match state:
		SPAWNING:
			if checkTimer.time_left == 0:
				checkTimer.start()
			state = ALIVE
			Global.enemies_in_the_level += 1

		ALIVE:
			if in_base_capture_radius:
				state = ATTACK
			if Target_Detected:
				animationPlayer.play("Walk")
				#Первый вариант, рабочий, движется к базе
				#if target != null:
					#direction_to_base = position.direction_to(target.global_position)
				#	look_at(base.global_position)
					
				#Движение к цели target
				#if target == null:
				#	target = Global.Global_target
				#direction_to_target = position.direction_to(target.global_position) #Движется напрямую без поиска пути
				direction_to_target = position.direction_to(pathfind_dir)
				
				#look_at(target.global_position) #Смотрит напрямую на цель, мимо следующих точек поиска пути, из-за чего уплывает в сторону
				look_at(pathfind_dir)

				#direction_to_base = base.global_position #Работает, но враг движется намного быстрее
			#velocity = velocity.move_toward(direction_to_base * MAX_SPEED, ACCELERATION * delta) #Старая версия с base вместо target
			#velocity = velocity.move_toward(direction_to_target * MAX_SPEED, ACCELERATION * delta) #Работало когда была база
			velocity = direction_to_target * (MAX_SPEED - outOfTiLeMapFriction)
			
			#apply_central_impulse(velocity) #Телепортирует к цели
			linear_velocity = velocity #Враг быстро, но равномерно приближается
			
			#Проверка на то, что не упирается в базу
			


		ATTACK:
			#Engine.time_scale = 0.01
			###Логика не стреляния по своим
			_alive_after_death() #Если враг умер, но почему-то ожил, то переходит
			#в состояние супер саняза так сказать
			
			if dont_shoot():
				weapon.shoot(self)
				if dont_shoot() != true:
					print(dont_shoot())
			###
			look_at(target.global_position) #Заменил base на target
			if checkTimer.time_left == 0:
				checkTimer.start()
			if attackCD.time_left == 0:
				attackCD.start()
				$EnemyShootSounds.play()

		STUN:
			if was_state == DEAD:
				pass
			stunParticles.emitting = true
			attackCD.stop()
			animationPlayer.play("stunned")
			direction_to_target = Vector2.ZERO
			if PiC: #Враг движется к курсору только если он присоединён
				velocity = velocity.move_toward(mouse_position-global_position, ACCELERATION * delta) 
				linear_velocity = velocity #Враг быстро, но равномерно приближается
			if PiC and LCE == self: 
				Dspring.connect_bodies(self, find_player())
			
			
			if StunT.time_left == 0:
				state = was_state 
				Global.PiC -= 1
				PiC = false
				#print("Я сбавляю глобал пик")
				#print("Узел врага делает PiC = false, потому что STUN ТАЙМЕР обнуляется")
				#GlobalSignals.emit_signal("changePiC", PiC) 
				#print("Узел врага при выходе из стана запускает сигнал changePiC, где PiC = false")
				Dspring.disconnect_joint()
				Dspring.jointLine.clear_points()
				wasLCE = null
				LCE = null
				
				#Если существуют инстацы
				if Child_Dspring_instance != null: 
				#if get_node("@DspringJoint@2") != null: 
					#if get_node_or_null(Dspring_instance) != null: #Выдаёт ошибку, потому гет нод нужен путь, а не сам объект
					Child_Dspring_instance.disconnect_joint()
					Child_Dspring_instance.jointLine.clear_points()
					LCE = null
					wasLCE = null
					connectedEnemy = null
					#print("Есть дети Dspring_instance")
				if LCE == self:
					LCE = null
					GlobalSignals.emit_signal("changeLCE", LCE) 
				if wasLCE == self:
					wasLCE = null
					GlobalSignals.emit_signal("changewasLCE", wasLCE) 
					velocity = velocity.move_toward(LCE.global_position - global_position, ACCELERATION * delta) 
					linear_velocity = velocity 

		DEAD:
			was_state = state
			DeathTimer.start()
			attackCD.stop()
			deathParticles.emitting = true
			if wasLCE == self and was_state == STUN:
				wasLCE = null
				GlobalSignals.emit_signal("changewasLCE", wasLCE)
				Global.PiC -= 1
				PiC = false
			if LCE == self:
				LCE = null
				GlobalSignals.emit_signal("changeLCE", LCE)
				Global.PiC -= 1
				PiC = false
			deathCounter += 1 #Отслеживание, умирал ли враг
			animationPlayer.play("death") 
			
			####В анимации смерти забит код смерти###
			#if DeathTimer.time_left == 0: 
			#	Global.score += 1
				#queue_free()
			##################
			
		QUARANTINED:
			#print("enemy quarantined")
			Global.enemies_in_the_level -= 1
			Global.score += 3
			queue_free()

		_:
			print ("Exception in states found")
			print("state not found = ", state)

#Две функции ниже исполняются через animationPlayer:
func plus_one_score():
	Global.score += 1

func EitL_minus_one():
	Global.enemies_in_the_level -= 1

#func _on_Check_timeout():
#	if state == DEAD: #Этот код не работает, он не запускается?
#		print("Global score 1")#
#		Global.score += 1#
#		#queue_free() #
#	elif state == SPAWNING:
#		state = ALIVE
#	elif state == ATTACK:
#		state = ALIVE
#	elif state == STUN:
#		pass


func _on_AttackCD_timeout():
		state = ATTACK

func stunned(damage):
	connection_sound.play()
	if state != STUN and state != ATTACK:
		was_state = state
	elif state == ATTACK:
		state = ALIVE
	state = STUN
	StunT.start()
	health -= damage
	if health <= 0:
		state = DEAD
	
	
	if PiC == false and LCE == null: #Только для  первичной связи с игроком
		#print("Enemy прогоняет ПиК ис Фалс")
		PiC = true
		Global.PiC += 1
		LCE = self
		GlobalSignals.emit_signal("changeLCE", self) 
		#emit_signal("enemyStunned", self, target) #Присоединяет себя и target (это кто?)
		#emit_signal("enemyStunned", self, find_player())
		Dspring.connect_bodies(self, find_player())
		
		#На связь с другими врагами
	elif PiC == true or LCE == self: #Повторный удар на себя
		#print("Повторный удар на себя")
		pass
		
	elif PiC == true and wasLCE == self: #Что это?
		print("Что это такое")
		pass
		
		#Нужно хранить в отдельной переменной узел врага, с которым идёт связь, без назначения извне. connectedEnemy
		#LCE и wasLCE назначаются извне от узла игрока
		#LCE для проверки, нужно ли создавать связь 
#	elif PiC == true and LCE != wasLCE: #Нужно чтобы Dspring_instance wasLCE создала с этим врагом связь
#		#Здесь ошибка к нулю парента!
#		if LCE.Dspring_instance.get_parent() == null: #Создаёт инстенс только со второго раза! Почему не с первого?
#			LCE.add_child(Dspring_instance)
#	#	LCE.Dspring_instance.connect_bodies(LCE, self) #Вызывает ошибку нулл!
#		wasLCE = LCE
#		GlobalSignals.emit_signal("changewasLCE", wasLCE)
#		LCE = self
#		GlobalSignals.emit_signal("changeLCE", self)
		
	elif PiC == false and wasLCE == null and LCE != self and LCE != null: #Присоединение пред врага к себе в первый раз
		#print("Присоединение  следующего, второго врага (будет wasLCE) к себе в первый раз")
		PiC = true
		wasLCE = LCE
		wasLCE.PiC = false
		GlobalSignals.emit_signal("changewasLCE", wasLCE)
		LCE = self
		GlobalSignals.emit_signal("changeLCE", self)
		Dspring.connect_bodies(self, find_player()) #Присоединяемся к игроку, затем нужно отсоединить пред. врага от игрока
		Global.PiC += 1
		wasLCE.Dspring.disconnect_joint() #Отсоединение
		wasLCE.Dspring.jointLine.clear_points()
		wasLCE.PiC = false
		wasLCE.connectedEnemy = self
		if wasLCE.Dspring_instance == null: #Проверяем, есть ли вторая пружина у пред. врага
			wasLCE_Dspring_instance = wasLCE.Dspring_inst_preload.instantiate()
			wasLCE.add_child(wasLCE_Dspring_instance)
			#wasLCE_Dspring_instance = Dspring_instance #Получаем ссылку на дочерний узел, так же можно делать через get_node
			wasLCE.Child_Dspring_instance = wasLCE_Dspring_instance #Назначение переменной, нужно в коде ниже
			#print("Добавляю Dspring_instance при wasLCE == ", wasLCE, "и LCE == ", LCE)
		#wasLCE.Dspring_instance.connect_bodies(wasLCE, LCE) #Присоед. пред. врага к себе
		wasLCE_Dspring_instance.connect_bodies(wasLCE, LCE) #Присоед. пред. врага к себе
	
	#elif PiC == false and wasLCE == null and LCE == self: #Оригинальная строчка, которая не срабатывала, хз почему
#	elif PiC == false and wasLCE == self and LCE != null: #Присоединение первого врага повторно, пока он в цепочке
#		print("Присоединение первого врага повторно")
#		PiC = true
#		wasLCE = LCE
#		GlobalSignals.emit_signal("changewasLCE", wasLCE)
#		LCE = self
#		GlobalSignals.emit_signal("changeLCE", self)
#		#Присоединяемся Dspring к игроку, затем нужно отсоединить пред. врага от игрока
#		Dspring.connect_bodies(self, find_player()) 
#		Global.PiC += 1
#		wasLCE.Dspring.disconnect_joint() #Отсоединение
#		wasLCE.Dspring.jointLine.clear_points()
#		wasLCE.PiC = false
#		wasLCE.connectedEnemy = self
#		#Затем отсоединяем инстанс дспринг от пред врага
#		Child_Dspring_instance.disconnect_joint()
#		Child_Dspring_instance.jointLine.clear_points()
#
#		#Старая версия проверяла наличие парента дспринг инстанца, но иногда оно выдавало парента первого присоединённого врага?
#		#if wasLCE.Dspring_instance.get_parent() == null: #Проверяем, есть ли вторая пружина у пред. врага
#		#Пробую через Child_Dspring_instance, и на данный момент заработало.
#		#Не до конца понимаю, почему иногда Dspring_instance он как бы в буфере висит, а иногда уже прикреплённый к конкретному предыдущему узлу
#		if Child_Dspring_instance != null:
#			#print("wasLCE без второй пружины")
#			wasLCE.add_child(Dspring_instance)
#			wasLCE_Dspring_instance = Dspring_instance #Получаем ссылку на дочерний узел, так же можно делать через get_node
#			wasLCE.Child_Dspring_instance = Dspring_instance #Назначение переменной, нужно в коде ниже
#			#print("Добавляю Dspring_instance при wasLCE == ", wasLCE, "и LCE == ", LCE)
#		#wasLCE.Dspring_instance.connect_bodies(wasLCE, LCE) #Присоед. пред. врага к себе
#		#print(wasLCE.Dspring_instance.get_parent())
#		wasLCE_Dspring_instance.connect_bodies(wasLCE, LCE) #Присоед. пред. врага к себе
	
	#Старый вариант, который не включал самого первого врага
	#elif PiC == true and connectedEnemy != null and wasLCE != null and LCE != self and LCE != null: #Присоединение пред врага к себе когда он уже был в цепочке (Если уже был wasLCE)
	elif PiC == false and connectedEnemy != null and wasLCE != null and LCE != self and LCE != null:
		#print("Присоединение пред врага к себе когда он уже был в цепочке")
		PiC = true
		wasLCE = LCE
		wasLCE.PiC = false
		GlobalSignals.emit_signal("changewasLCE", wasLCE)
		LCE = self
		GlobalSignals.emit_signal("changeLCE", self)
		Dspring.connect_bodies(self, find_player()) #Присоединяемся к игроку, затем нужно отсоединить пред. врага от игрока
		Global.PiC += 1
		wasLCE.Dspring.disconnect_joint() #Отсоединение
		wasLCE.Dspring.jointLine.clear_points()
		#Отсоединяем у LCE (self) Dspring_instance то, что у него было, т.к. он теперь ведущий враг
		#1 вариант
		#if get_node("@DSpringJoint@2"):
		#	Child_Dspring_instance = get_node("@DSpringJoint@2") #!= null:
		#	Child_Dspring_instance.disconnect_joint() 
		#2 вариант
		Child_Dspring_instance.disconnect_joint() #Так как мы назначили его в предыдущем блоке
		Child_Dspring_instance.jointLine.clear_points()
		connectedEnemy = null
		
		#Затем у предыдущего врага связываем с нами его Dspring_instance
		#Проверяем, есть ли вторая пружина у пред. врага
		
		#if wasLCE.Dspring_instance.get_parent() == null: #Почему-то выдаёт, будто не равняется нул, хотя если я ставлю принт, то пишет нул? Фигня какая-то
		#print("втф, такого не должно быть физически")
		#print(Dspring_instance.get_parent())
		
		#Возникает проблема когда E1-E2-E3-E2-E1, E2-E1 нет соединения
		#E1-E2-E3-E4-E3!
		#Нужно если атака идёт на wasLCE, т.к. у него не будет чайлдИнстанс
		if wasLCE.Child_Dspring_instance == null:
			wasLCE_Dspring_instance = wasLCE.Dspring_inst_preload.instantiate()
			wasLCE.add_child(wasLCE_Dspring_instance)
			wasLCE.Child_Dspring_instance = wasLCE_Dspring_instance #Назначение переменной, нужно в коде ниже
		wasLCE.Child_Dspring_instance.connect_bodies(wasLCE, LCE)
		wasLCE.connectedEnemy = LCE
		#wasLCE.Child_Dspring_instance = wasLCE_Dspring_instance  #На удаление, вызывает ошибку нулл


	#Присоединение нового (третьего) врага к существующей цепочке
	elif PiC == false and connectedEnemy == null and wasLCE != null and LCE != self and LCE != null and LCE.connectedEnemy == null:
		#print("Присоединение нового (третьего) врага к существующей цепочке, если последний враг не был ни к кому присоединён")
		#print("wasLCE = ", wasLCE)
		#print("LCE = ", LCE)
		#######
		PiC = true
		wasLCE = LCE
		wasLCE.PiC = false
		GlobalSignals.emit_signal("changewasLCE", wasLCE)
		LCE = self
		GlobalSignals.emit_signal("changeLCE", self)
		Dspring.connect_bodies(self, find_player()) 
		Global.PiC += 1
		wasLCE.Dspring.disconnect_joint()
		wasLCE.Dspring.jointLine.clear_points()
		#####
		#Проверяем, есть ли вторая пружина у пред. врага
		#Старая версия
		#if wasLCE.Dspring_instance.get_parent() != wasLCE: 
		if wasLCE.Child_Dspring_instance == null:
			#print("Добавляю инстант 2-ому врагу")
			wasLCE_Dspring_instance = wasLCE.Dspring_inst_preload.instantiate() #На этой строчке не создаёт!!!!
			wasLCE.add_child(wasLCE_Dspring_instance)
			#wasLCE_Dspring_instance = Dspring_instance #Получаем ссылку на дочерний узел, так же можно делать через get_node
			wasLCE.Child_Dspring_instance = wasLCE_Dspring_instance #Назначение переменной, нужно в коде ниже
		#print("wasLCE перед кодом = ", wasLCE)
		#print(wasLCE.Dspring_instance.get_parent())
		#print(wasLCE.Dspring_instance)
		wasLCE.Child_Dspring_instance.connect_bodies(wasLCE, LCE)
		wasLCE.connectedEnemy = LCE
		
	elif PiC == false and connectedEnemy == null and wasLCE != null and LCE != self and LCE != null and LCE.Child_Dspring_instance == null:
		#print("Присоединение нового (третьего) врага к существующей цепочке, если последний враг был в цепочке")
		#######
		PiC = true
		wasLCE = LCE
		wasLCE.PiC = false
		GlobalSignals.emit_signal("changewasLCE", wasLCE)
		LCE = self
		GlobalSignals.emit_signal("changeLCE", self)
		Dspring.connect_bodies(self, find_player()) 
		Global.PiC += 1
		wasLCE.Dspring.disconnect_joint()
		wasLCE.Dspring.jointLine.clear_points()
		#####
		#Проверяем, есть ли вторая пружина у пред. врага
		if wasLCE.Child_Dspring_instance == null:
			wasLCE_Dspring_instance = wasLCE.Dspring_inst_preload.instantiate() #На этой строчке не создаёт!!!!
			wasLCE.add_child(wasLCE_Dspring_instance)
			wasLCE.Child_Dspring_instance = wasLCE_Dspring_instance #Назначение переменной, нужно в коде ниже
		###Делаем связь от пред врага к последнему
		wasLCE.Child_Dspring_instance.connect_bodies(wasLCE, LCE)
		
		
		
		#Затем нужно создать если кто-то из цепочки умер, LCE или wasLCE
	elif PiC == true and wasLCE != null: #Если уже был wasLCE
		#print("Если уже был wasLCE")
		LCE = self 
		GlobalSignals.emit_signal("changeLCE", self)
		Dspring.connect_bodies(self, find_player())
		if Dspring_instance.get_parent() == null:
			add_child(Dspring_instance) #Должно быть только один раз!!!
			#print("get_parent != null")
		wasLCE.Dspring.connect_bodies(wasLCE, LCE)
	
	else:
		print("Непонятные условия соединения")
#	if enemy метод на соприкосновение с базой in_group("base"):
#		state == QUARANTINED


func handle_hit(damage: int):
	if state == DEAD:
		pass
	else:
		health -= damage + Global.player_attack_bonus
		damageParticles.emitting = true
		if health <= 0:
			death_sound.play()
			state = DEAD

func receive_knockback(damage_source_pos: Vector2, received_damage: int):
	if receives_knockback:
		var knockback_direction = damage_source_pos.direction_to(self.global_position)
		var knockback_strength = received_damage * knockback_modifier
		var knockback = knockback_direction * knockback_strength

		global_position += knockback


func _on_BaseDetection_body_entered(body): #Атакует игрока
	#print ("target == body ", target, '==', body)
	#if body.is_in_group("base"): #Player - атакует игрока; base - атакует базу
	if body == target:
		base = body
		Target_Detected = true

	#base=target  #Агрит на игрока
	#pass


func _on_AttackRadius_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	#print(body)
	if body == find_player() and state != STUN and Global.enemies_agro_mod: #Чтобы заагривался на игрока, подходящего вплотную
		target = find_player()
		state = ATTACK
		#Специально не ставлю остановку, типо он по пути отстреливается и идёт дальше

	if body == target and state != STUN:
		state = ATTACK
		#receive_knockback(velocity, 1) #Тормозит врага перед базой, слишком резко и криво, я отказался
		linear_velocity = Vector2.ZERO #Враг останавливается перед целью



func _on_DeathTimer_timeout(): #Этот код тоже не работает! 
	emit_signal("tree_exiting") # До него не доходит?
	Global.score += 1 #
	#queue_free()  #



func _on_AttackFollowRadius_body_exited(body):
	#print('_on_AttackFollowRadius_body_exited, body = ', body, 'target = ', target)
	if body == target and body == primal_target:
		if state == ATTACK: 
			state = ALIVE

	if body == target and body != primal_target:
		target = primal_target
		if state == ATTACK:
			state = ALIVE

func makepath() -> void:
	if target != null:
		nav_agent.target_position = target.global_position
	else:
		#print("No target for PathFind!")
		pass


func _on_check_timeout():
	makepath()
#	_PiC_check()
	#print("direction_to_target = ", direction_to_target)
	#print("velocity = ", velocity)

func dont_shoot():
	if RayCast_middle.get_collider(): 
		if (RayCast_middle.get_collider()).is_in_group("enemy"):
			RayCastEnemy_middle = true
		else:
			RayCastEnemy_middle = false

	if RayCast_top.get_collider(): 
		if (RayCast_top.get_collider()).is_in_group("enemy"):
			RayCastEnemy_top = true
		else:
			RayCastEnemy_top = false

	if RayCast_bottom.get_collider():
		if (RayCast_bottom.get_collider()).is_in_group("enemy"):
			RayCastEnemy_bottom = true
		else: 
			RayCastEnemy_bottom = false

	if RayCastEnemy_middle and RayCastEnemy_top and RayCastEnemy_bottom:
		return false
	else:
		return true

func _on_Character_collided(_collision):
	if _collision.is_in_group('TileMap'):
		outOfTiLeMapFriction = 0
		#print(_collision)
#RayCast_middle.get_collider()).is_in_group("enemy"):

func _body_exited_collider(_collision):
	if _collision.is_in_group('TileMap'):
		outOfTiLeMapFriction = 45

func _alive_after_death():
	if deathCounter > 0:
		health +=5
		target = find_player()
		deathCounter -= 1
		aliveAfterDeathParticles.emitting = true

#func _PiC_check(): #Выполняет проверку, присоединён ли в игроку враг
	#Нужно для того, чтобы отключать движение к курсору, когда переднего врага из
	#цепочки захватили в базу, а остальные остались отдельно
#	if state == STUN and PiC == null:
#		linear_velocity = velocity #Враг быстро, но равномерно приближается
	
