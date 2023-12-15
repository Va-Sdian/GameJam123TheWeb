extends Area2D
class_name Bullet
var damage: int = 1
@export var speed: int = 300 #300 Стандарт
@onready var flyParticles = $flyParticles
#var position = self.global_position
#var vec2 = Vector2(vec3.x, vec3.z)
#var vec3 = Vector3(direction.x, direction.y, 0)
var gun_end_direction := Vector2.ZERO
@onready var gun_end_direction_vec3 = Vector3(self.gun_end_direction.x, self.gun_end_direction.y, 0)
@onready var self_vec3_position = Vector3(self.global_position.x, self.global_position.y, 0)

func _physics_process(delta: float):
	if gun_end_direction != Vector2.ZERO:
		flyParticles.emitting = true
		flyParticles.rotation = 3
		flyParticles.process_material.direction = gun_end_direction_vec3 - self_vec3_position
		#print(flyParticles.process_material.direction)
		var velocity = gun_end_direction * speed
		global_position += velocity * delta

func set_direction(_direction):
	self.gun_end_direction = _direction
	rotation += _direction.angle()


func _on_KillTimer_timeout() -> void:
	queue_free()


func _on_Bullet_body_entered(body):
	#print (direction)
	if body.has_method("receive_knockback"):
		body.receive_knockback(self.global_position, damage)
	if body.has_method("handle_hit"):
		body.handle_hit(damage)
		queue_free()
	elif body.has_method("get_bounce"):
		queue_free()
