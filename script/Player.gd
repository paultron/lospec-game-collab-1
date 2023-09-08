extends CharacterBody2D


@onready var line: FishingLine = $Line

# If space, cast line
func _unhandled_input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and !line.cast:
			line.cast = true
			get_tree().root.get_node("main/Camera2D/AnimationPlayer").play("pan")



