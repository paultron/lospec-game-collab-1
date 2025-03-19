extends PlayerState
class_name IdleState

func enter(previous_state_path:String, data := {}):
	player.sprite_2d.play("idle")
	
func physics_update(delta):
	if Input.is_action_just_pressed("space"):
		finished.emit(CHARGING)
