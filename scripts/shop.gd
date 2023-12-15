extends Node2D

#@onready var player_heath = Global.player_health_bonus
@onready var base_heath = Global.base_health_mult
@onready var player_attack = Global.player_attack_bonus
@onready var player_heath_score_label = $PlayerHealthNode/PlayerHealthscore
@onready var base_heath_score_label = $BasehealthNode/Basehealthscore
@onready var player_attack_score_label = $PlayerAttackNode/PlayerAttackscore
@onready var score_label = $ScoreNode/Score

#Buttons
@onready var Playerhealthbuybutton = $PlayerHealthNode/Playerhealth
@onready var Basehealthbuybutton = $BasehealthNode/Basehealth
@onready var PlayerAttackButton = $PlayerAttackNode/PlayerAttackButton

@onready var PlayerhealthsellButton = $PlayerHealthNode/PlayerhealthsellButton
@onready var BasehealthsellButton = $BasehealthNode/BasehealthsellButton
@onready var PlayerAttackSellButton = $PlayerAttackNode/PlayerAttackSellButton

func _ready():
	Playerhealthbuybutton.connect('pressed', Playerhealthbuy)
	Basehealthbuybutton.connect('pressed', Basehealthbuy)
	PlayerAttackButton.connect('pressed', PlayerAttackbuy)
	
	PlayerhealthsellButton.connect('pressed', Playerhealthsell)
	BasehealthsellButton.connect('pressed', Basehealthsell)
	PlayerAttackSellButton.connect('pressed', PlayerAttackSell)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	player_heath_score_label.text = str(1 + Global.player_health_bonus)
	base_heath_score_label.text = str(5 + Global.base_health_mult)
	player_attack_score_label.text = str(1 + Global.player_attack_bonus)
	score_label.text = str(Global.score)

func Playerhealthbuy():
	if Global.score > 4:
		Global.player_health_bonus += 1
		Global.score -= 5

func Basehealthbuy():
	if Global.score > 1:
		Global.base_health_mult +=1
		Global.score -= 2

func PlayerAttackbuy():
	if Global.score > 19:
		Global.player_attack_bonus += 1
		Global.score -= 20


func Playerhealthsell():
	if Global.player_health_bonus > 0:
		Global.player_health_bonus -= 1
		Global.score += 5

func Basehealthsell():
	if Global.base_health_mult > 0:
		Global.base_health_mult -= 1
		Global.score += 2

func PlayerAttackSell():
	if Global.player_attack_bonus >= 0:
		Global.player_attack_bonus -= 1
		Global.score += 20


