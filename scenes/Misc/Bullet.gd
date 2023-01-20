extends Area2D
class_name Bullet
var damage: int = 1
export (int) var speed = 300

var direction := Vector2.ZERO

func _physics_process(delta: float):
	if direction != Vector2.ZERO:
		var velocity = direction * speed
		global_position += velocity * delta

func set_direction(direction: Vector2):
	self.direction = direction
	rotation += direction.angle()


func _on_KillTimer_timeout() -> void:
	queue_free()


func _on_Bullet_body_entered(body):
	if body.has_method("handle_hit"):
		body.handle_hit(damage)
		queue_free()
	elif body.has_method("get_bounce"):
		queue_free()
