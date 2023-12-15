extends CharacterBody2D

@onready var node_a = self.get_path()
@onready var node_b = get_node("../KinBod2")
#export var node_b: NodePath
@onready var jointLine = $Line2D
@onready var selected = false
var mouse_offset = null
var line_offset = null


func _physics_process(_delta):

	if node_b:
		NetJointLine(node_a, node_b)
		#var object = node_b
		#if object:
			#NetJointLine(object.global_position)
		#else:
		#	node_b = ''
			
	if selected:
		followMouse()
		#print("Selected!")

func followMouse():
	position = get_global_mouse_position() + mouse_offset
	#print("following mouse!")

func NetJointLine(_node_a, p_node_b):
	jointLine.points = []
	#jointLine.add_point(node_a.global_position) #Жалуется на путь
	jointLine.add_point(Vector2.ZERO)
	#print("NetJointLine is running!", node_b)
	jointLine.add_point(p_node_b.global_position - self.global_position)


func _on_KinBod1_input_event(_viewport, event):
	#print("pre input event!")
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#print("input event!")
		if event.pressed:
			mouse_offset = position - get_global_mouse_position()
			selected = true
		else:
			selected = false
