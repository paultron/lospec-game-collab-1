extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event):
	if event is InputEventKey and event.keycode == KEY_SPACE and event.pressed:
		get_parent().start_loading_screen()
		queue_free()
