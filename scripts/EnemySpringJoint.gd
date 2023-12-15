extends DampedSpringJoint2D

@onready var jointLine = $jointLine
var rotation_fix = 0

# Connect both bodies to the joint, save the relative rotation, and
# connect signals to disconnect the joint if either body is deleted
func connect_bodies(body1 : PhysicsBody2D, body2 : PhysicsBody2D):
	if get_parent() != null:
		node_a = body1.get_path() #Узел самого врага
		node_b = body2.get_path() #Узел игрока, либо второго врага в последствии
	#print("connect_bodies is running!")
	
	# This rotation fix is used in physics_process to keep the
	# rotation of the parent fixed relative to another body as it rotates
		var angle_to_body = (global_position - body2.global_position).angle()
		#print(get_parent())
		rotation_fix = get_parent().global_rotation - angle_to_body

		if body1.is_connected("tree_exiting",Callable(self,"disconnect_joint")) != true:
	# The game will crash if connected nodes are removed from the scene
			body1.connect("tree_exiting",Callable(self,"disconnect_joint"))
			body1.connect("tree_exiting",Callable(jointLine,"clear_points")) #Работает, хотя я не до конца это понимаю
		if body2.is_connected("tree_exiting",Callable(self,"disconnect_joint")) != true:
			body2.connect("tree_exiting",Callable(self,"disconnect_joint"))
			body2.connect("tree_exiting",Callable(jointLine,"clear_points")) 	#То же самое делаю с линиями



func _physics_process(_delta):
	# All of the standard physics joints allow free rotation around the joint
	# connection. Godot 3.2 doesn't have the concept of a "fixed joint"
	# but there is a proposal.
	#
	# This fixes the rotation of the parent object relative to the rotation
	# of the connected object. This makes the pinjoint work like the two objects
	# are welded together -- a Fixed Joint3D.
	if node_b:
		var object : PhysicsBody2D = get_node(node_b)
		if object:
			var angle_to_body = (global_position - object.global_position).angle()
			get_parent().set_deferred("rotation", angle_to_body + rotation_fix) 
			#Из-за кода выше вращается в сторону игрока
			#Видимо set_deferred обращается к первому условию как переменной родителя
			#и второе условие назначает эту переменную
			NetJointLine(object.global_position)
			#print(angle_to_body) #выдаёт занчения от 3.134479 до такого же отрицательного
			jointLine.set_deferred("rotation", -rotation_fix - angle_to_body)
		else:
			node_b = ''
			
	#if node_b != null:
	#	NetJointLine(node_b)


func disconnect_joint():
	node_a = ''
	node_b = ''



func NetJointLine(_node_b):
	jointLine.points = []
	jointLine.add_point(Vector2.ZERO) 
	#jointLine.add_point(self.global_position)
	#print("NetJointLine is running!", node_b)
	jointLine.add_point(_node_b - self.global_position)
