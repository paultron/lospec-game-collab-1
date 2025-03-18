@tool
extends Sprite2D
class_name PowerBar

var power: float = 0
var actual_power: float:
	get: 
		return fmod(power, 1)
const top := 4
const bottom := 92

@onready var cap: TextureRect = $Mask/Cap

func on_resize():
	# var cap = $Mask.get_node("Cap")
	if cap.position.y < 9 or cap.position.y > 82:
		cap.hide()
	else:
		cap.show()

func on_power_applied(applied: float):
	power = applied
	
	var mask: ColorRect = $Mask
	mask.size.y = clamp(int(actual_power * bottom), top, bottom)
