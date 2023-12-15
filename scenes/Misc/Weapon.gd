extends Node2D
class_name Weapon

@export var Bullet: PackedScene
@export var BulletCapture: PackedScene

@onready var gun_end = $GunEnd
@onready var gun_position = $GunDirection
@onready var shoot_cooldown = $Cooldown
#@export var PIC: bool

func shoot(caller):
	if shoot_cooldown.is_stopped() and Bullet != null:
		var bullet_instance = Bullet.instantiate() #Видимо это и спавнит узел пули
		var direction = (gun_position.global_position - gun_end.global_position).normalized()
		GlobalSignals.emit_signal("bullet_fired", bullet_instance, gun_end.global_position, direction)
		shoot_cooldown.start()
		if "Player" in str(caller):
			$ShootSounds.play()


func capture(LCE, wasLCE):
	if shoot_cooldown.is_stopped() and BulletCapture != null:
		var bulletCapture_instance = BulletCapture.instantiate() #Создаёт instance, типо переменную?, но не сам узел!
		var direction = (gun_position.global_position - gun_end.global_position).normalized()
		GlobalSignals.emit_signal("bulletCapture_fired", bulletCapture_instance, gun_end.global_position, direction, LCE, wasLCE)
		$CaptureSounds.play()
		shoot_cooldown.start()
