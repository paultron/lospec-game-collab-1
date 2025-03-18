extends Node2D

signal casted
signal powerApplied(power: float)

var reeling = false
var lettingOut = false

@onready var line: FishingLine = $Line
@onready var power_bar: PowerBar = %PowerBar

var space_pressed = false # Added variable to track space key state

# When SPACE_KEY is held, charge up the line.castingDistance
# When SPACE_KEY is released, cast line
# When Z_KEY is held, reel in line
# When X_KEY is held, let out line
func _input(event):
	if get_parent().catching:
		return
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and get_parent().get_node("buttons").visible == true \
		and not get_parent().has_node("loadingScreen"):
			if event.pressed and !space_pressed and line.castingPhase == 0:  # Check if the space key is pressed
				line.resetPhases()
				space_pressed = true
				line.castingPhase = 1
				print("Casting Phase 1")
				if !line.cast:
					line.castingTime = 0.0
			elif !event.pressed and line.castingPhase == 1:
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
			line.castingDistance = clamp(power_bar.actual_power * line.maxCastingDistance, 0.0, line.maxCastingDistance)

func on_animation_finished():
	if $Sprite2D.animation == "cast":
		$Sprite2D.play("recovery")
		line.castingPhase = 2
		line.cast = true
		reeling = false
		lettingOut = false
		get_tree().root.get_node("main/Camera2D/AnimationPlayer").play("pan")
	elif $Sprite2D.animation == "recovery":
		$Sprite2D.play("idle")
