extends TextureProgressBar

@onready var full_player_health = 1 + Global.player_health_bonus
@onready var player_health_1_percent: float = float(full_player_health)/100
@onready var targets =  get_tree().get_nodes_in_group("target")
@onready var player = null


func _ready():
	#if Global.player != null:
		#print("global player != null")
		#print("full_player_health = ", Global.player_health, ', Player = ', Global.player)
		#print('player_min_health = ', Global.player.min_health)
	#elif Global.find_player() != null:
	#	full_player_health = Global.player_health
	#	player_health_1_percent = float(full_player_health)/100
	if find_player() != null:
		player = find_player()
		Global.player = player

func _process(_delta):
	_player_health_update()

func _player_health_update():
	if Global.player != null:
		value = Global.player.health / player_health_1_percent


func player_damage_recieved(health) -> void:
	value = int(health / player_health_1_percent)
	_color_change()
	#print('full_player_health = ',full_player_health, ', player_health_1_percent = ', player_health_1_percent)


func find_player():
	for _target in targets:
		if str(_target).contains("Player"):
			player = _target.get_node("../Player")
		return player


func _color_change():
	if player != null and player.health > full_player_health:
		tint_progress = Color(29/255.0, 51/255.0, 255/255.0, 1)
	else:
		tint_progress = Color(1,1,1,1)
