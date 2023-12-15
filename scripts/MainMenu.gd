extends Node2D
var config = ConfigFile.new()
const SAVE_FILE_PATH = "user://saves/"
const SAVE_FILE_NAME = 'Leaderboard.tres'
const SECURITY_KEY = "DAVEKATISTHEBEST69"


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.score = 0
	_load_encrypted_leaderboard()


func _load_encrypted_leaderboard():
	if FileAccess.file_exists(SAVE_FILE_PATH + SAVE_FILE_NAME):
		config.load_encrypted_pass(SAVE_FILE_PATH + SAVE_FILE_NAME, SECURITY_KEY)
		#print(config.get_sections())
		if config.has_section('Music'):
			#Сделал кривую проверку, чтобы значения не были null, иначе не загружать
			#В идеале сделать нужно не через ошибку?
			if config.get_value('Music', "volume_db") != null: 
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Music'), config.get_value('Music', "volume_db"))
			if config.get_value('SFX', "volume_db") != null: 
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index('SFX'), config.get_value('SFX', "volume_db"))
