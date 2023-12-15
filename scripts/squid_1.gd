extends RigidBody2D

@export var ACCELERATION = 200
@export var MAX_SPEED = 210 #110 Скорость игрока
@export var FRICTION = 700
@onready var outOfTiLeMapFriction = 100
@onready var direction = Vector2.RIGHT
@onready var direction_to_target = Vector2.ZERO
@onready var damageParticles = $damageParticles
@onready var DeathTimer = $DeathTimer
@onready var deathParticles = $deathParticles
@onready var aliveAfterDeathParticles = $aliveAfterDeathParticles
@onready var checkTimer = $Check
@onready var targetChangeTimer = $TargetChangeTimer
@onready var targets =  get_tree().get_nodes_in_group("Squid_Marker")
var target = null
var prev_target_for_dontmove = null
@onready var player = null
@onready var base = null
@onready var player_detection_area = $Player_detection
@onready var player_nearby: bool = false
@onready var Target_detection_area = $Target_detection
@onready var _dont_move = false

@export var receives_knockback: bool = true
@export var knockback_modifier: float = 2
@onready var health = 8
@onready var is_dead:bool = false

@onready var sprite = $Sprite2D

#var motion = Vector2()
@onready var velocity = Vector2.ZERO
@onready var nav_agent := $NavigationAgent as NavigationAgent2D


@onready var player_health_restore = 10
@onready var base_health_restore = 15


@onready var death_sound = $death_sound
@onready var reincarnation_sound = $reincarnation_sound


func _ready():
	targetChangeTimer.connect('timeout',find_target)
	checkTimer.connect('timeout', makepath)
	Target_detection_area.connect("body_entered", _stop_be_mad_when_you_at_target_please)
	Target_detection_area.connect("body_exited", _be_free_target_exited_your_area)
	nav_agent.connect("target_reached", _target_reached)
	player_detection_area.connect("body_entered", _player_detected)
	player_detection_area.connect("body_exited", _player_leaves)
	DeathTimer.connect('timeout', _death)
	health += Global.enemies_health_bonus
	find_player()
	find_base()
	checkTimer.start()

func find_target(): #работает
	target = targets[randi() % targets.size()]
	_dont_move = false


func _on_check_timeout():
	print("check timeout")
	makepath()


func makepath() -> void:
	if target != null:
		#look_at(target.global_position) 
		nav_agent.target_position = target.global_position
	else:
		#print("No target for PathFind!")
		pass
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	#Заменил base на target
	var pathfind_dir = nav_agent.get_next_path_position()
	_color_change()
	
	
	if checkTimer.time_left == 0:
		checkTimer.start()

	if target != null and _dont_move != true and prev_target_for_dontmove != target:
		direction_to_target = position.direction_to(pathfind_dir)
		look_at(pathfind_dir)
		velocity = direction_to_target * (MAX_SPEED - outOfTiLeMapFriction)
	elif target == null and _dont_move:
		#print("dont move")
		direction_to_target = Vector2.ZERO 
		velocity = Vector2.ZERO
		look_at(Global.player.global_position)
		#PathfindingGlobal.clear_path()
	elif prev_target_for_dontmove == target and _dont_move != true:
		direction_to_target = Vector2.ZERO 
		velocity = Vector2.ZERO
		look_at(Global.player.global_position)
	elif target == null and _dont_move != true:
		direction_to_target = Vector2.ZERO 
		velocity = Vector2.ZERO
		look_at(Global.player.global_position)	
			
	linear_velocity = velocity #Враг быстро, но равномерно приближается


func handle_hit(damage: int):
	if is_dead == true:
		pass
	else:
		find_target()
		health -= damage + Global.player_attack_bonus
		damageParticles.emitting = true
		if health <= 0:
			is_dead = true
			if player != null:
				player.handle_hit(-player_health_restore)
			if base != null:
				base.handle_hit(-base_health_restore)
			DeathTimer.start()
			deathParticles.emitting = true


func _death():
	death_sound.play()
	Global.score += 10
	queue_free()


func find_player():
	for _target in targets:
		player = _target.get_node("../Player")
		return player

func find_base():
	for _target in targets:
		#if str(_target).contains("Base"): #Почему-то не работает
		base = _target.get_node("../Base")
		return base


func receive_knockback(damage_source_pos: Vector2, received_damage: int):
	if receives_knockback:
		var knockback_direction = damage_source_pos.direction_to(self.global_position)
		var knockback_strength = received_damage * knockback_modifier
		var knockback = knockback_direction * knockback_strength

		global_position += knockback


func _stop_be_mad_when_you_at_target_please(_detection):
	#if _detection == target:
	#	print("_dont_move = true")
	#	_dont_move = true
	pass

		
func _be_free_target_exited_your_area(_detection):
	#if _detection == target:
	#	_dont_move = false
	#	print("_dont_move = false")
	pass
	
	
func _target_reached():
	_dont_move = true
	if prev_target_for_dontmove != target:
		prev_target_for_dontmove = target
		target = null
	else:
		pass


func _player_detected(_detected):
	if _detected == player:
		player_nearby = true
		find_target()

func _player_leaves(_leaved):
	if _leaved == player:
		player_nearby = false

func _color_change():
	#var color_change = self.global_position - player.global_position
	var distance_to_player = self.global_position.distance_to(player.global_position) #минимум 20.5
	var _one_precent_of_programmed_distance = 2
	var _one_precent_of_real_distance = distance_to_player/100
	var color_change = _one_precent_of_real_distance / _one_precent_of_programmed_distance
	#print("_one_precent_of_real_distance = ", _one_precent_of_real_distance, 'color_change = ', color_change)

	modulate = Color(105/255.0, 1, 92/255.0, color_change)
