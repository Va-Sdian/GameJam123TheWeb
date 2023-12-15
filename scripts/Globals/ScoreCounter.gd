extends NinePatchRect


@onready var score_label = $Score_Label

#func player_damage_recieved(health) -> void:
#	score_label.text = Global.score

func _process(_delta):
	score_label.text = str(Global.score)
