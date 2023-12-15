extends Node2D

#Отвечает за создание узлов пуль
#bullet_instance, gun_end.global_position, direction
func handle_bullet_spawned(bullet: Bullet, _position: Vector2, direction: Vector2):
	add_child(bullet)
	bullet.global_position = _position
	bullet.set_direction(direction)

func handle_bulletCapture_spawned(bullet: BulletCapture, _position: Vector2, direction: Vector2, _LCE, _wasLCE):
	add_child(bullet)
	bullet.global_position = _position
	bullet.set_direction(direction)
	#bullet.PiC  = PiC
	bullet.LCE  = _LCE
	bullet.wasLCE  = _wasLCE
