extends Node2D
@onready var score_label = $CanvasLayer/CanvasLayer2/HBoxContainer/Score
@onready var save_score_button = $SaveScoreToLeaderboard
@onready var input_line = $PanelContainer/HBoxContainer/Input

const SAVE_FILE_PATH = "user://saves/"
const SAVE_FILE_NAME = 'Leaderboard.tres'
const SECURITY_KEY = "DAVEKATISTHEBEST69"

#@onready var data_received
#var leaderboard_Data = LeaderboardData.new()
var config = ConfigFile.new()


func _ready():
	verify_save_directory(SAVE_FILE_PATH)
	input_line.grab_focus()
	save_score_button.connect('pressed', _on_save_button_pressed)
	_load_encrypted_leaderboard()


func _process(_delta):
	score_label.text = str(Global.score)
	if Input.is_action_pressed("ui_accept"):
		_on_save_button_pressed()


func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)


func _on_save_button_pressed():
	#leaderboardData.name = input_line.text
	#leaderboardData.score = Global.score
	#save_data_without_encryption()
	save_data(SAVE_FILE_PATH + SAVE_FILE_NAME)
	
	input_line.clear()
	save_score_button.disabled = true


#func save_data_without_encryption():
#		leaderboard_Data.add_new_leaderboard_place(input_line.text, Global.score)
#		ResourceSaver.save(leaderboard_Data, SAVE_FILE_PATH + SAVE_FILE_NAME) 


func _load_encrypted_leaderboard():
	if FileAccess.file_exists(SAVE_FILE_PATH + SAVE_FILE_NAME):
		config.load_encrypted_pass(SAVE_FILE_PATH + SAVE_FILE_NAME, SECURITY_KEY)
		#print(config.get_value("audio_bus_name", "volume_db"))


func save_data(_Path):
	var leaderboard_array: Array
	
	if config != null and config.has_section("leaderboard"):
		leaderboard_array = config.get_value("leaderboard", "leaderboard_array")
	
	leaderboard_array.append_array([{'leaderboard_name':input_line.text, 'score':Global.score}])
	config.set_value("leaderboard", "leaderboard_array", leaderboard_array)
	
	config.save_encrypted_pass(_Path, SECURITY_KEY)
	Global.score = 0
