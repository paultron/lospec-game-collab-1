@tool
extends Sprite2D
class_name Bar
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_resize():
	var cap = $Mask.get_node("Cap")
	if cap.position.y < 9:
		cap.hide()
	elif cap.position.y > 82:
		cap.hide()
	else:
		cap.show()
		
