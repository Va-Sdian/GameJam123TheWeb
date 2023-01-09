extends RigidBody2D



class_name Enemy

var health: float = 100.0
var speed: float = 200.0
#var target: PlayerCharacter

func _physics_process(delta: float) -> void:
#	if target == null: target = get_tree().get_nodes_in_group("Player")[0]
	if target != null: 
		velocity = position.direction_to(target.position) * speed
		move_and_slide()
		look_at(target.global_position)

func apply_damage(damage: float) -> void:
	health = clamp(health - damage, 0.0, 100.0)
	if health == 0.0:
		GameManager.handle_enemy_death()
		queue_free()




#func _ready():
#	$AnimatedSprite.playing = true
#	var mob_types = $AnimatedSprite.frames.get_animation_names()
#	$AnimatedSprite.animation = mob_types[randi() % mob_types.size()]
#	pass


#func _on_VisibilityNotifier2D_screen_exited():
#	queue_free()
