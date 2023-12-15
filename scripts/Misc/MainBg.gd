extends Sprite2D

@export var d := 0.0
@export var radius := 20.0
@export var speed := 1.0

func _physics_process(delta: float) -> void:
	d += delta
	
	position =  Vector2(
		sin(d * speed) * radius,
		cos(d * speed) * radius
	) + Vector2(518, 350)
