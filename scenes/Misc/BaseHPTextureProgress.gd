extends TextureProgressBar

@onready var full_base_health  = 5 + Global.base_health_mult
@onready var base_health_1_percent: float = float(full_base_health)/100
@onready var targets =  get_tree().get_nodes_in_group("target")
@onready var base = null


func _ready():
	value = 100
	#Первоначальное значение, полная полоска здоровья (в процентах)
	if Global.base != null:
		value = full_base_health / base_health_1_percent
		#print('base hp texture progress ready ')
	if find_base() != null:
		base = find_base()
		Global.base = base


func _process(_delta):
	_base_health_update()


func _base_health_update():
	if Global.base != null:
		value = Global.base.health / base_health_1_percent

func base_damage(health) -> void:
	#value может быть только в процентах, нужно перевести значения
	value = int(health / base_health_1_percent)
	_color_change()
	#print('Health (', health, ') / 1 percent (', base_health_1_percent, ') = value ', value)

func _color_change():
	if Global.base != null and Global.base.health > full_base_health:
		tint_progress = Color(29/255.0, 51/255.0, 255/255.0, 1)
	else:
		tint_progress = Color(1,1,1,1)

func find_base():
	for _target in targets:
		if str(_target).contains("Base"):
			base = _target.get_node("../Base")
			#print("found base")
			return base
