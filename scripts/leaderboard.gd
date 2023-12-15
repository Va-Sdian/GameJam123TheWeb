extends Node2D

@onready var LeaderboardLabel = $CanvasLayer/LeaderboardLabel
@onready var LeaderboardDeleteFirstButton = $CanvasLayer/DeleteLeaderboard
@onready var LeaderboardDeleteConfirmButton = $CanvasLayer/DeletingLeaderboard/DeleteLeaderboard2
@onready var LeaderboardDeleteReurnButton = $CanvasLayer/DeletingLeaderboard/NotDeleteLeaderboard
#@onready var leaderboard_parsed_file
@onready var leaderboard_array: Array

const SAVE_FILE_PATH = "user://saves/"
const SAVE_FILE_NAME = 'Leaderboard.tres'
const SECURITY_KEY = "DAVEKATISTHEBEST69"
var config = ConfigFile.new()
var leaderboard_string: String
	
	
func _ready():
	if FileAccess.file_exists(SAVE_FILE_PATH + SAVE_FILE_NAME):
		_load_encrypted_leaderboard()
	else:
		LeaderboardDeleteFirstButton.disabled = true
	
	LeaderboardDeleteFirstButton.connect('pressed', _delete_leaderboard_visible)
	LeaderboardDeleteConfirmButton.connect('pressed', delete_encrypted_leaderboard)
	LeaderboardDeleteReurnButton.connect('pressed', _delete_leaderboard_not_visible)
	#print("Error, no leaderboard")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _delete_leaderboard_visible():
	$CanvasLayer/DeletingLeaderboard.visible = true


func _delete_leaderboard_not_visible():
	$CanvasLayer/DeletingLeaderboard.visible = false


#func _load_leaderboard(): #Загрузка из сохранённого файла без защиты
#	leaderboard_Data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
#	_leaderboard_sort(leaderboard_Data)
#	LeaderboardLabel.text = str(leaderboard_string)


func _load_encrypted_leaderboard():
	if FileAccess.file_exists(SAVE_FILE_PATH + SAVE_FILE_NAME):
		config.load_encrypted_pass(SAVE_FILE_PATH + SAVE_FILE_NAME, SECURITY_KEY)
		leaderboard_string = ""
		if config.has_section("leaderboard"):
			leaderboard_array = config.get_value('leaderboard', 'leaderboard_array')
			#print("leaderboard_array = ", leaderboard_array)
			_leaderboard_sort(leaderboard_array)
		LeaderboardLabel.text = str(leaderboard_string)
	else:
		printerr("Cannot open non-existent file at %s!" % [SAVE_FILE_PATH + SAVE_FILE_NAME])


func _leaderboard_sort(_leaderboardData):
	#Нужно сделать, чтобы он сортировал и выводил ТОЛЬКО секцию "leaderboard_name"
	#А то они и другие настройки пытается загребсти
	var a = 0
#	var PackedStringArrayForScore
	_leaderboardData.sort_custom(sort_by_score)
	for i in _leaderboardData:
		a += 1
		#PackedStringArrayForScore = 
		leaderboard_string = leaderboard_string + (str(a, '. ', i['leaderboard_name'], '     ', i['score'], '\n'))
		#print(a, '.', i)
		#print('leaderboard_string = ', leaderboard_string)
		#print(a, '. ', i['name'], '     ', i['score'], '\n')
		#return leaderboard_string


func sort_by_score(a, b):
	if a['score'] > b['score']:
		return true
	return false


#func delete_leaderboard(): #Для незащищённого
#	leaderboard_Data._delete_leaderboard()
#	ResourceSaver.save(leaderboard_Data, save_file_path + save_file_name)
#	_delete_leaderboard_not_visible()
#	LeaderboardDeleteFirstButton.disabled = true
#	_load_leaderboard()

func delete_encrypted_leaderboard():
	config.erase_section('leaderboard')
	config.save_encrypted_pass(SAVE_FILE_PATH + SAVE_FILE_NAME, SECURITY_KEY)
	_delete_leaderboard_not_visible()
	LeaderboardDeleteFirstButton.disabled = true
	_load_encrypted_leaderboard()

func _leaderboard_unsorted(_leaderboardData):
	var a = 0
	for i in _leaderboardData.leaderboard_array:
		a += 1
		leaderboard_string.insert(0, str(i))
		#print(a, '.', i)
		print('leaderboard_string = ', leaderboard_string)
		print(a, '. ', i['leaderboard_name'], '     ', i['score'], '\n')

#Доступ к значению ключа - сравнивание величины ключа. Если ключ больше то пишем?
