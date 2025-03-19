extends AnimatedSprite2D

class_name Fish

@export var data: FishData
var lastMoved: int = 0
var state: FishState = FishState.idle
var attraction: Node2D = null

enum FishState { idle, swimLeft, swimRight, attracted, hooked}
enum HookState { struggle, rest, caught}

func _ready():
	play("default")
	var isLeft = randf() > 0.5
	if isLeft:
		flip(false)
		state = FishState.swimRight
	else:
		flip(true)
		state = FishState.swimLeft

func _process(delta: float):
	if state == FishState.hooked:
		flip(false)
		# Set position such that the mouth is at the hook
		global_position = attraction.global_position
		return
	if position.x < -20 or position.x > 280:
		queue_free()
	if state == FishState.attracted:
		var mouth = $mouthRight if flip_h else $mouthLeft
		# Get direction to attraction
		var dir = (attraction.global_position - mouth.global_position).normalized()
		if dir.x < 0 and attraction.global_position.x < global_position.x:
			flip(false)
			mouth = $mouthLeft
		elif dir.x > 0 and attraction.global_position.x > global_position.x:
			flip(true)
			mouth = $mouthRight
		# Move such that the mouth moves towards the attraction
		position += mouth.global_position.direction_to(attraction.global_position) * 10 * delta
		if mouth.global_position.distance_to(attraction.global_position) < 2:
			bite()
		return
	if Time.get_ticks_msec() - lastMoved > 3000:
		lastMoved = Time.get_ticks_msec()
		if state == FishState.idle and randf() > 0.5:
			if randf() > 0.5:
				flip(true)
				state = FishState.swimRight
			else:
				flip(false)
				state = FishState.swimLeft
		elif randf() > 0.2:
			state = FishState.idle
		
			
	if state == FishState.swimLeft:
		position.x -= 10 * delta
	elif state == FishState.swimRight:
		position.x += 10 * delta
	
func flip(is_flipped: bool):
	flip_h = is_flipped
	$Exclamation.flip_h = is_flipped
	$Exclamation.position = $exRight.position if is_flipped else $exLeft.position

func on_awareness_entered(other: Area2D):
	if state == FishState.hooked:
		return
	if other.get_parent() is Fish:
		# swim away from the other fish
		if other.position.x > position.x:
			state = FishState.swimLeft
			flip(false)
		else:
			state = FishState.swimRight
			flip(true)
		lastMoved = Time.get_ticks_msec()
	elif other.get_parent().name == "LineEnd" and other.get_parent().get_parent().hooked == null:
		print("attracted")
		# swim towards the line end
		state = FishState.attracted
		attraction = other
		flip(false)

		$Exclamation.show()
		$Exclamation.play("default")
		$Exclamation.animation_finished.connect(func(): 
			await get_tree().create_timer(0.5).timeout
			$Exclamation.hide()
		)
	else:
		state = FishState.idle

func bite():
	if attraction.get_parent().get_parent().hooked != null:
		state = FishState.idle
		return
	print("bite")
	# nibble on the line
	if randi_range(0, 12) < int(data.size)**2:
		return
	print("HIT!")
	state = FishState.hooked
	# Set all other attracted fish to idle
	for fish in get_tree().get_nodes_in_group("fish"):
		if fish.state == FishState.attracted and fish != self:
			fish.state = FishState.idle
	attraction.get_parent().get_parent().hooked = self
