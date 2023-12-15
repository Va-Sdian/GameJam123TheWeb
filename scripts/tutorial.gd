extends Node2D

@onready var page1 = $Page_1
@onready var page2 = $Page_2
@onready var page3 = $Page_3
@onready var page4 = $Page_4
@onready var next_button_label = $NextButton/Label
# Called when the node enters the scene tree for the first time.
func _ready():
	next_button_label.text = "NEXT"
	$NextButton.connect('pressed', next_page)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func next_page():
	if page1.visible == true:
		page1.visible = false
		page2.visible = true
	elif page2.visible == true:
		page2.visible = false
		page3.visible = true
	elif page3.visible == true:
		page3.visible = false
		page4.visible = true
	elif page4.visible == true:
		next_button_label.text = "END"
