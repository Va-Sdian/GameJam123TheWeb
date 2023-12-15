extends Resource
class_name LeaderboardData


#@export var name: String
#@export var score: int
@export var leaderboard_array = []

#@export var leaderboard_array = [] # Нужно для add_new_leaderboard_place
#var name: String # Нужно для add_new_leaderboard_place
#var score: int # Нужно для add_new_leaderboard_place
#В видео переменные для сохранения делаются как @export
#Пока их такими не делаю, только словарь оставляю


#func add_new_leaderboard_place(_name: String, _value: int): #Работало в незашифрованных сохранениях, но в шифре уже не пашет
#	#Недостаточно компететен, чтобы понять, почему, поэтому не использую
#	name = _name
#	score = _value
	#leaderboard_dict[name] = score 
	#print(leaderboard_dict)
#	leaderboard_array.append_array([{'name':_name, 'score':_value}])


#func _delete_leaderboard():
#	leaderboard_array.clear()


#Попытка сделать зашифрованный список

#func add_new_leaderboard_place(_name: String, _value: int): 
#	name = _name
#	score = _value
#	leaderboard_array.append_array([{'name':_name, 'score':_value}])
