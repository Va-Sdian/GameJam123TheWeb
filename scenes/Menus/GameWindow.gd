extends Node

onready var bullet_manager = $BulletManager
onready var player: Player = $Player
onready var TestHPLabel = $TestHPLabel
onready var player_health = $CanvasLayer/GUI/HUD/HPCounter
onready var PlayerHPTextureProgress = $CanvasLayer/GUI/HUD/PlayerHPTextureProgress
onready var base_health = $CanvasLayer/GUI/TopHContainer/HPCounter
onready var BaseHPTextureProgress = $CanvasLayer/GUI/TopHContainer/BaseHPTextureProgress
onready var GUI = $CanvasLayer/GUI
onready var music = $LevelMusic

func _ready():
	GlobalSignals.connect("bullet_fired", bullet_manager, "handle_bullet_spawned")
	GlobalSignals.connect("bulletCapture_fired", bullet_manager, "handle_bulletCapture_spawned")
	GlobalSignals.connect("player_damage", TestHPLabel, "player_damage_recieved")
	GlobalSignals.connect("player_damage", player_health, "player_damage_recieved")
	GlobalSignals.connect("player_damage", PlayerHPTextureProgress, "player_damage_recieved")
	GlobalSignals.connect("base_damage", base_health, "base_damage")
	GlobalSignals.connect("base_damage", BaseHPTextureProgress, "base_damage")
	GlobalSignals.connect("game_over", GUI, "game_over")
	GlobalSignals.connect("game_over", self, "game_over")
	
func game_over():
	music.stop()

