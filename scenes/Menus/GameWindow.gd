extends Node

onready var bullet_manager = $BulletManager
onready var player: Player = $Player

func _ready():
	GlobalSignals.connect("bullet_fired", bullet_manager, "handle_bullet_spawned")
	GlobalSignals.connect("bulletCapture_fired", bullet_manager, "handle_bulletCapture_spawned")
