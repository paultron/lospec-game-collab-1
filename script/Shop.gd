extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func open():
	get_parent().get_node("buttons").hide()
	show()

func close():
	get_parent().get_node("buttons").show()
	hide()
