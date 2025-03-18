extends Sprite2D


signal click
 
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(_event):
	if Input.is_action_just_pressed("accept"):
		click.emit()
		queue_free()
