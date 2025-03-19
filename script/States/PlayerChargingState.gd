extends PlayerState


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("accept"):
		#casted.emit()
		print("released space")

func enter(previous_state_path:String, data := {}):
	print("Entered charging state")
	%Line.resetPhases()
	#space_pressed = true
	%Line.castingPhase = 1
	print("Casting Phase 1")
	if !%Line.cast:
		%Line.castingTime = 0.0
