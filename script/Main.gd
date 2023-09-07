extends Node2D

const waterLevel: int = 34

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	# If the user clicks on the water
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Get the mouse position
		var mousePos = get_global_mouse_position()
		# If the mouse is between 190 and 220
		if mousePos.y < 220 and mousePos.y > 190:
			# If the mouse is between 190 and 220
			if mousePos.x < 256 and mousePos.x > 60:
				# spawn splash sprite
				var splash = load("res://prefab/splash.tscn").instantiate()
				get_parent().add_child(splash)
				# move to mouse position
				splash.position = mousePos
				z_index = -1
			

