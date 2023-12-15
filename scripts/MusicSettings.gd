extends VBoxContainer


@export var label: String
@export var bus_name: String
@export var audio_stream_player_path: NodePath


var audio_stream_player: AudioStreamPlayer

@onready var play_button = $HBoxContainer/Play
@onready var stop_button = $HBoxContainer/Stop
#@onready var save_button = $'../../SaveButton'
const SAVE_FILE_PATH = "user://saves/"
const SAVE_FILE_NAME = 'Leaderboard.tres'
const SECURITY_KEY = "DAVEKATISTHEBEST69"
var config = ConfigFile.new()
var bus_volume_db


func _ready():
	#save_button.connect('pressed', save_data)
	$Label.text = label
	audio_stream_player = get_node(audio_stream_player_path)
	_load_encrypted_leaderboard()


func _on_HSlider_value_changed(value):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	_load_encrypted_leaderboard()
	save_data()
	if value > $HSlider.min_value:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, value)
	else:
		AudioServer.set_bus_mute(bus_idx, true)



func _on_Play_pressed():
	audio_stream_player.play()
	play_button.disabled = true
	stop_button.disabled = false


func _on_Stop_pressed():
	audio_stream_player.stop()
	play_button.disabled = false
	stop_button.disabled = true


func _load_encrypted_leaderboard():
	if FileAccess.file_exists(SAVE_FILE_PATH + SAVE_FILE_NAME):
		config.load_encrypted_pass(SAVE_FILE_PATH + SAVE_FILE_NAME, SECURITY_KEY)
		if config.has_section(bus_name) and config.get_value(bus_name, "volume_db") != null: 
			#Сделал кривую проверку, чтобы значения не были null, иначе не загружать
			#В идеале сделать нужно не через ошибку?
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), config.get_value(bus_name, "volume_db"))


func save_data():
	bus_volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name))
	config.set_value(bus_name, "volume_db", bus_volume_db)
	
	config.save_encrypted_pass(SAVE_FILE_PATH + SAVE_FILE_NAME, SECURITY_KEY)
