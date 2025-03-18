extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func open():
	%TopButtons.hide()
	show()
	play("open")

func on_opened():
	if (frame == 0): return

func close():
	play_backwards("open")

func on_closed():
	if (frame != 0): return
	%TopButtons.show()
	hide()
