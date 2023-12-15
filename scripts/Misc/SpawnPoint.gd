extends Marker2D

signal spawned(spawn)

#@export var enemy = PackedScene
@onready var basic_enemy = preload("res://scenes/Viruses/Enemy1.2.tscn")
@onready var fat_enemy = preload("res://scenes/Viruses/Enemy1_fat.tscn")
@onready var yellow_enemy = preload("res://scenes/Viruses/Enemy1_yellow.tscn")
@onready var health_enemy_squid = preload("res://scenes/Viruses/squid_1.tscn")

#@onready var new_basic_enemy = basic_enemy.instance() 
@onready var rng = RandomNumberGenerator.new()
@onready var minTimer = 3.1
@onready var maxTimer = 15.1
@onready var SpawnCD = $SpawnCD

func _ready():
	rng.randomize()
	var my_random_number = rng.randf_range(minTimer, maxTimer)
	SpawnCD.wait_time = my_random_number
	SpawnCD.start()

func spawn():
	var new_basic_enemy = _type_of_spawned_enemies_randomize().instantiate()
	add_child(new_basic_enemy)
	new_basic_enemy.set_as_top_level(true) #Что это?
	new_basic_enemy.global_position = global_position
	
	emit_signal("spawned", new_basic_enemy)
	return new_basic_enemy

func _type_of_spawned_enemies_randomize():
	var type_of_enemy
	var result = randf()
	if result <= Global.enemy_basic_type_chance:
		type_of_enemy = basic_enemy
	elif result <= Global.enemy_fat_type_chance and result > Global.enemy_basic_type_chance:
		type_of_enemy = fat_enemy
	elif result <= Global.enemy_yellow_type_chance and result > Global.enemy_fat_type_chance:
		type_of_enemy = yellow_enemy
	else:
		type_of_enemy = health_enemy_squid
	return type_of_enemy


func _on_SpawnCD_timeout():
	rng.randomize()
	var my_random_number = rng.randf_range(0, maxTimer)
	spawn()
	SpawnCD.wait_time = my_random_number
	SpawnCD.start()
