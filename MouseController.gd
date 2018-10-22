extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var press_location;

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			print("Mouse Click at:  ", get_global_mouse_position())
		else:
			print("Mouse unclicked at:  ", get_global_mouse_position())
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
