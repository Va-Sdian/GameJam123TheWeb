extends CharacterBody2D
class_name Player


signal player_damage(damage)
#signal player_global_position()
signal game_over()
#signal changePiC(PlayerIsConnected)
#@export (PackedScene) var Bullet

const MAX_SPEED = 120 #Без тайлмапов: 120
const ACCELEARTION = 800 #Без тайлмапов: 800
const FRICTION = 10000 #Без тайлмапов: 10000 Нужен для торможения игрока. 
#Чем выше - тем быстрее тормозит игрок, когда не нажаты кнопки движения
@onready var outOfTiLeMapFriction = 80

const min_health: int = 1
@onready var health: int = min_health + Global.player_health_bonus
#var velocity = Vector2.ZERO
#var p_g_p = global_position
var p_g_p = get_transform()
@onready var player = $PlayerCollision
@onready var DeathTimer = $DeathTimer
@onready var weapon = $AntiVirus/Weapon
@onready var PlayerIsConnected: bool = false 
@onready var LCE: Node2D
@onready var wasLCE: Node2D
@onready var damageParticles = $damageParticles
@onready var deathParticles = $deathParticles
@onready var AreaForDetection = $AreaForDetection
#@onready var Sum_PiC = Global.PiC

func _ready():
	$AreaForDetection.connect('body_entered',Callable(self, '_on_Character_collided'))
	$AreaForDetection.connect('body_exited',Callable(self, '_body_exited_collider'))




func _physics_process(delta):
	PlayerIsConnectedSummCheck()
	
	var input_vector = Vector2.ZERO
	if health != 0:
		input_vector.x = Input.get_axis("ui_left", "ui_right")
		input_vector.y = Input.get_axis("ui_up", "ui_down")
		input_vector = input_vector.normalized()
		#print(p_g_p)
	#if Input.is_action_pressed("ui_accept"):
	#	handle_hit(1)
#		print("Die!")
		#print("Health:", health)
	
	if Input.is_action_pressed("shoot"):
		weapon.shoot(self) 
	if Input.is_action_pressed("capture"):
		weapon.capture(LCE, wasLCE)
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * (MAX_SPEED - outOfTiLeMapFriction), ACCELEARTION * delta)
		$AnimationTree.set("parameters/Transition/transition_request", "crawl") 
		$Legs.rotation = velocity.angle() + 80.05
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		if health != 0:
			$AnimationTree.set("parameters/Transition/transition_request", "idle") 
#			animation.stop()
#		$Legs.frame = 0 #Прикольней же когда останавливается в движении
	
	var mouse_position = get_global_mouse_position()
	if mouse_position != player.global_position:
		$AntiVirus.look_at(mouse_position)
		$AntiVirus.rotation_degrees -= 90
		
	#self.changePiC.connect(func():PlayerIsConnected == !PlayerIsConnected)
	#self.changePiC.connect(func():PlayerIsConnected == true)
	#GlobalSignals.changePiC.connect(func():print("Player receive PiC signal")) #тут должен быть не селф а враг!
	
	set_velocity(velocity)
	move_and_slide()
	#velocity = velocity


func handle_hit(damage):
	damageParticles.emitting = true
	health = clamp(health - damage - Global.enemies_attack_bonus, 0.0, 100.0)
	GlobalSignals.emit_signal("player_damage", health)
	if health == 0.0 and DeathTimer.time_left == 0:
		DeathTimer.start()
		$AnimationTree.set("parameters/Transition/transition_request", "death") 
		deathParticles.emitting = true
		if DeathTimer.time_left != 0:
			GlobalSignals.emit_signal("game_over")

func PlayerIsConnectedSummCheck():
	if Global.PiC == 0:
		PlayerIsConnected = false
		LCE = null
		wasLCE = null
	else:
		PlayerIsConnected = true
	
func _on_Character_collided(_collision):
	if _collision.is_in_group('TileMap'):
		outOfTiLeMapFriction = 0
		#print(_collision)
#RayCast_middle.get_collider()).is_in_group("enemy"):

func _body_exited_collider(_collision):
	if _collision.is_in_group('TileMap'):
		outOfTiLeMapFriction = 80
		#print(_collision)


#func changePiC(PiC):
#	#print("Игрок получает сигнал changePiC, где PiC = ", PiC)
#	if PiC == true:
#		PlayerIsConnected = true
#	else:
#		PlayerIsConnected = false
		#print("После проверки, что полученный от врага PiC из тру, меняет в себе, и в итоге PlayerIsConnected = ", PlayerIsConnected)

func changeLCE(_LCE): 
	#print("Игрок получает сигнал changeLCE, где LCE = ", _LCE)
	LCE = _LCE
	
func changewasLCE(_wasLCE): 
#print("Игрок получает сигнал changeLCE, где LCE = ", _LCE)
	wasLCE = _wasLCE

#func 
