extends CharacterBody2D

var reeling = false
var lettingOut = false
@onready var line: FishingLine = $Line
signal casted
signal powerApplied(power: float)

var space_pressed = false # Added variable to track space key state

# When SPACE_KEY is held, charge up the line.castingDistance
# When SPACE_KEY is released, cast line
# When Z_KEY is held, reel in line
# When X_KEY is held, let out line
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE:
			if event.pressed and !space_pressed:  # Check if the space key is pressed
				line.resetPhases()
				space_pressed = true
				line.castingPhase = 1
				print("Casting Phase 1")
				if !line.cast:
					line.castingTime = 0.0
			elif !event.pressed:
				space_pressed = false
				casted.emit()
				$Sprite2D.play("cast")
		elif event.keycode == KEY_Z and line.cast:
			reeling = event.pressed
		elif event.keycode == KEY_X and line.cast:
			lettingOut = event.pressed

func _ready():
	$Sprite2D.play("idle")

func _physics_process(delta):
	if line.cast:
		if reeling:
			line.reel(delta)
		elif lettingOut:
			line.reel(-delta)
	else:
		if space_pressed:
			line.castingTime += delta
			powerApplied.emit(line.castingTime)
			line.castingDistance = clamp(get_parent().get_node("Power").actual_power * line.maxCastingDistance, 0.0, line.maxCastingDistance)

func on_animation_finished():
	if $Sprite2D.animation == "cast":
		$Sprite2D.play("idle")
		line.applyCastPower(get_parent().get_node("Power").actual_power)
		line.cast = true
		reeling = false
		lettingOut = false
		get_tree().root.get_node("main/Camera2D/AnimationPlayer").play("pan")
