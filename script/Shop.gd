extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func open():
	%TopButtons.hide()
	show()

func close():
	%TopButtons.show()
	hide()
