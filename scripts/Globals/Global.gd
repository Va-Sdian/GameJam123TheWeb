extends Node

#Должно быть onready из-за порядка исполнения
#(export var) -> (onready var) -> ( _ready() ) -> (var/const, depending on which one was called first in the script)
#Соединение сигналов происходит в функции _ready, и после её идёт загрузка обычных переменных
# @onready же загружается до исполнения функции _ready()
@onready var score: int = 0
@onready var previous_score: int = 0
@onready var base_health_mult: int = 35 #35
@onready var base_health_now: int = 0
@onready var PiC: = 0 #Player is Connected Summ
@onready var enemies_in_the_level: int = 0
@onready var Global_target
@onready var targets =  get_tree().get_nodes_in_group("target")
@onready var player: Player  = null
@onready var player_health = null
@onready var base = null

#Возможные модели поведения поиска пути
@onready var pathfind_state = Basic
@onready var current_level = null

#Поведение враго на уровне
@onready var player_agression = 0
@onready var enemies_health_bonus = 1
@onready var enemies_attack_bonus = 0
@onready var player_health_bonus = 9
@onready var player_attack_bonus = 0
@onready var enemies_agro_mod = false
@onready var enemy_basic_type_chance = 0.85
@onready var enemy_fat_type_chance = 0.93
@onready var enemy_yellow_type_chance = 0.98
@onready var enemy_healthsquid_type_chance = 1


enum {
	Basic,
	nav_agent_pathfind, 
	AStar, #2
	}

func _ready():
	if find_base() != null:
		Annoucment_Global_target(find_base())
		base_hp()
	if find_player() != null:
		player = find_player()
		player_health = player.min_health + player_health_bonus
		#print("Global: player = ", player)
		#print("Global: player.health = ", player.health)
		#print("Global: player_health = ", player_health)

func _process(_delta):
	pass
	
func PathFinding_model_state():
	if enemies_in_the_level <=30:
		pathfind_state = nav_agent_pathfind
	elif enemies_in_the_level > 30:
		pathfind_state = Basic

func Annoucment_Global_target(new_global_target):
	Global_target = new_global_target
	#print("Global_target = ", Global_target)


func find_player():
	for _target in targets:
		if str(_target).contains("Player"):
			player = _target.get_node("../Player")
			player_health = player.health
		return player


func find_base():
#	print(get_tree())
#	print("Targets = ", targets)
	for _target in targets:
		if str(_target).contains("Base"):
			base = _target.get_node("../Base")
			#print("found base")
			return base

func base_hp():
	base_health_now = find_base().health


#func level_finished():
#	print("Global func level_finished")
	
