extends Area2D
class_name BulletCapture
var damage: int = 0
@export var speed: int = 300
#var PiC: bool = false #PlayerIsConnected
var LCE: Node2D #Last connected Enemy
var wasLCE: Node2D
var CoI = 1 #Count of Interactions. Количество возможного взаимодействия пули

var direction := Vector2.ZERO

func _physics_process(delta: float):
	if direction != Vector2.ZERO:
		var velocity = direction * speed
		global_position += velocity * delta

func set_direction(_direction):
	self.direction = _direction
	rotation += _direction.angle()


func _on_KillTimer_timeout() -> void:
	queue_free()


func _on_Bullet_body_entered(body):
	if body.has_method("stunned") and CoI != 0:
		#print('BulletCapture содержит в себе переменную, что PiC = ', PiC)
		#body.PiC = PiC
		CoI -= 1
		body.LCE = LCE
		body.wasLCE = wasLCE
		body.stunned(damage)
		queue_free()
	elif body.has_method("get_bounce"):
		queue_free()
 
