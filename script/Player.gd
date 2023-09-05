extends CharacterBody2D

# Variables
var speed: float = 300.0

# Input
var input_vector = Vector2()

func _physics_process(delta: float) -> void:
	_handle_input()
	_move_character(delta)
	# If position is outside of the screen clamp inside
	if position.x < 0:
		position.x = 0
	if position.x > get_viewport_rect().size.x - $ColorRect.size.x:
		position.x = get_viewport_rect().size.x - $ColorRect.size.x
	if position.y < 0:
		position.y = 0
	if position.y > get_viewport_rect().size.y - $ColorRect.size.y:
		position.y = get_viewport_rect().size.y - $ColorRect.size.y


func _handle_input() -> void:
    # Reset input vector
	input_vector = Vector2()

	# Get input
	if Input.is_action_pressed("right"):
		input_vector.x = 1
	elif Input.is_action_pressed("left"):
		input_vector.x = -1
	if Input.is_action_pressed("down"):
		input_vector.y = 1
	elif Input.is_action_pressed("up"):
		input_vector.y = -1

	# Normalize the input vector to ensure consistent movement speed
	input_vector = input_vector.normalized()

func _move_character(_delta: float) -> void:
	velocity = input_vector * speed
	move_and_slide()
	


