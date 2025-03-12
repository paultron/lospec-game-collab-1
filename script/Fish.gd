extends AnimatedSprite2D

class_name Fish

@export var data: FishData
var lastMoved: int = 0
var state: State = State.idle
var attraction: Node2D = null

enum State { idle, swimLeft, swimRight, attracted, hooked}
enum HookState { struggle, rest, caught}

func _ready():
	play("default")
	var isLeft = randf() > 0.5
	if isLeft:
		flip(false)
		state = State.swimRight
	else:
		flip(true)
		state = State.swimLeft

func _process(delta: float):
	if state == State.hooked:
		flip(false)
		# Set position such that the mouth is at the hook
		global_position = attraction.global_position
		return
	if position.x < -20 or position.x > 280:
		queue_free()
	if state == State.attracted:
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
		if state == State.idle and randf() > 0.5:
			if randf() > 0.5:
				flip(true)
				state = State.swimRight
			else:
				flip(false)
				state = State.swimLeft
		elif randf() > 0.2:
			state = State.idle
		
			
	if state == State.swimLeft:
		position.x -= 10 * delta
	elif state == State.swimRight:
		position.x += 10 * delta

func flip(boolean: bool):
	flip_h = boolean
	if boolean:
		$Exclamation.flip_h = true
		$Exclamation.position = $exRight.position
	else:
		$Exclamation.flip_h = false
		$Exclamation.position = $exLeft.position

func on_awareness_entered(other: Area2D):
	if state == State.hooked:
		return
	if other.get_parent() is Fish:
		# swim away from the other fish
		if other.position.x > position.x:
			state = State.swimLeft
			flip(false)
		else:
			state = State.swimRight
			flip(true)
		lastMoved = Time.get_ticks_msec()
	elif other.get_parent().name == "LineEnd" and other.get_parent().get_parent().hooked == null:
		print("attracted")
		# swim towards the line end
		state = State.attracted
		attraction = other
		flip(false)

		$Exclamation.show()
		$Exclamation.play("default")
		$Exclamation.animation_finished.connect(func(): 
			var timer = Timer.new()
			timer.wait_time = 0.5
			timer.one_shot = true
			add_child(timer)
			timer.start()
			await timer.timeout
			$Exclamation.hide()
			timer.queue_free()
		)
	else:
		state = State.idle

func bite():
	if attraction.get_parent().get_parent().hooked != null:
		state = State.idle
		return
	print("bite")
	# nibble on the line
	if randi_range(0, 12) < int(data.size)**2:
		return
	print("HIT!")
	state = State.hooked
	# Set all other attracted fish to idle
	for fish in get_tree().get_nodes_in_group("fish"):
		if fish.state == State.attracted and fish != self:
			fish.state = State.idle
	attraction.get_parent().get_parent().hooked = self
