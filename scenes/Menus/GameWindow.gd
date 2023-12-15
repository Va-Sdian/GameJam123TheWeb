extends Node

@onready var bullet_manager = $BulletManager
#@onready var player: Player = $Player #Убрал отсюда под иф, а потом и вовсе в глобал
#onready var TestHPLabel = $TestHPLabel
@onready var player_health = $CanvasLayer/GUI/VBoxContainer/HUD/HPCounter
@onready var PlayerHPTextureProgress = $CanvasLayer/GUI/VBoxContainer/HUD/PlayerHPTextureProgress
@onready var base_health = $CanvasLayer/GUI/VBoxContainer/TopHContainer/HPCounter
@onready var base = null
@onready var BaseHPTextureProgress = $CanvasLayer/GUI/VBoxContainer/TopHContainer/BaseHPTextureProgress
@onready var GUI = $CanvasLayer/GUI
@onready var music = $LevelMusic
#@onready var enemy1 = $Enemys/Enemy1




func _ready():
	GlobalSignals.connect("bullet_fired",Callable(bullet_manager,"handle_bullet_spawned"))
	GlobalSignals.connect("bulletCapture_fired",Callable(bullet_manager,"handle_bulletCapture_spawned"))
#	GlobalSignals.connect("player_damage",Callable(TestHPLabel,"player_damage_recieved"))
	GlobalSignals.connect("player_damage",Callable(player_health,"player_damage_recieved"))
	GlobalSignals.connect("player_damage",Callable(PlayerHPTextureProgress,"player_damage_recieved"))
	GlobalSignals.connect("base_damage",Callable(base_health,"base_damage"))
	GlobalSignals.connect("base_damage",Callable(BaseHPTextureProgress,"base_damage"))
	GlobalSignals.connect("game_over",Callable(GUI,"game_over"))
	GlobalSignals.connect("game_over", game_over)
	GlobalSignals.connect("start_level_timer",Callable(GUI, "start_level_timer"))
	GlobalSignals.connect("level_completed",Callable(GUI, "_on_level_completed_timer_timeout"))
	
	# Обновляем списки хп у базы и игрока

	if $Player != null:
		Global.player = $Player
		GlobalSignals.emit_signal("player_damage",(Global.player.health))
		GlobalSignals.connect("changePiC",Callable(Global.player,"changePiC"))
		GlobalSignals.connect("changeLCE",Callable(Global.player,'changeLCE'))
		GlobalSignals.connect("changewasLCE",Callable(Global.player,'changewasLCE'))
	
	level_start() #Запускаем таймер уровня
	get_tree().paused = false
	
	#GlobalSignals.connect("enemyStunned",Callable(DampedSpringJoint2D,"connect_bodies"))
	#get_tree().call_group('enemy', 'set_target', Global.player) #Что это делает? Назначает в группе enemy таргет = плеер?
	#enemy1.target = Player

func set_target_base():
	if base != null:
		get_tree().call_group('enemy', 'set_target', base)
		GlobalSignals.emit_signal("base_damage", (base.health)) #Обновляет список хп у базы
	else: print("No base found")

func set_target_player():
	get_tree().call_group('enemy', 'set_target', Global.player)

func game_over():
	#print("GameWindows music stop")
	music.stop()

func level_start():
	match get_tree().current_scene.name:
		#null:
			#Global.current_level = "FirstLevel"
			#GUI.start_level_timer(15) #70
			#print("match on the null level")
		"MainMenu":
			Global.current_level = null
			Global.player_agression = 0
			Global.enemies_health_bonus = 0
			Global.enemies_attack_bonus = 0
			Global.score = 0
		"FirstLevel":
#			Global.find_base()
#			Global.find_player()
			Global.score = Global.previous_score #При перезапуске уровня должно обнулить очки
			Global.current_level = "FirstLevel"
			Global.player_agression = 0
			Global.enemies_health_bonus = 0
			Global.enemies_attack_bonus = 0
			Global.enemies_agro_mod = false
			GUI.start_level_timer(70) #70
		"SecondLevel":
#			Global.find_base()
#			Global.find_player()
			Global.score = Global.previous_score
			Global.current_level = "SecondLevel"
			Global.player_agression = 0.2 #0.2
			Global.enemies_health_bonus = 1 #1
			Global.enemies_agro_mod = true
			GUI.start_level_timer(100) #100
		"ThirdLevel":
#			Global.find_base()
#			Global.find_player()
			Global.score = Global.previous_score
			Global.current_level = "ThirdLevel"
			Global.player_agression = 0.4 #0.4
			Global.enemies_health_bonus = 2 #2
			Global.enemies_attack_bonus = 1 #1
			Global.enemies_agro_mod = true
			GUI.start_level_timer(160) #160
		_:
			print("неизвестный мэтч на определениии уровня")


#func next_level(current_level):
#	music.stop()
#	if Global.current_level == "MainMenu":
#		get_tree().change_scene("GameWindow")
#	elif Global.current_level == "GameWindow":
#		get_tree().change_scene("SecondLevel")
#	elif Global.current_level == "SecondLevel":
#		get_tree().change_scene("ThirdLevel")
#	elif Global.current_level == "ThirdLevel":
#		get_tree().change_scene("you_win")
