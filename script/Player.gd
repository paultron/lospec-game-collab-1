extends CharacterBody2D

var reeling = false
var lettingOut = false
@onready var line: FishingLine = $Line

# If space, cast line
func _unhandled_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and !line.cast:
			line.cast = true
			get_tree().root.get_node("main/Camera2D/AnimationPlayer").play("pan")
		if event.keycode == KEY_Z and line.cast:
			reeling = event.pressed
			print(line.letOut)
		elif event.keycode == KEY_X and line.cast:
			lettingOut = event.pressed

func _physics_process(delta):
	if reeling:
		line.reel(delta)
	elif lettingOut:
		line.reel(-delta)



