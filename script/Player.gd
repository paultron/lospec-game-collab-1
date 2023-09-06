extends CharacterBody2D

# Variables
var speed: float = 300.0
@onready var rodBegin: Vector2 = $RodBegin.position
@onready var rodEnd: Vector2 = $RodEnd.position

# Input
var input_vector = Vector2()

func _ready():
	pass

func _draw():
	# Draw rod
	draw_line(rodBegin, rodEnd, Color(0, 0, 0), 2.0)

func _process(_delta):
	queue_redraw()

func _physics_process(delta: float) -> void:
	_handle_input()
	_move_character(delta)
	# If position is outside of the screen clamp inside
	if position.x < 0:
		position.x = 0
	if position.x > 40:
		position.x = 40


func _handle_input() -> void:
    # Reset input vector
	input_vector = Vector2()

	# Get input
	if Input.is_action_pressed("right"):
		input_vector.x = 1
	elif Input.is_action_pressed("left"):
		input_vector.x = -1
	# if Input.is_action_pressed("down"):
	# 	input_vector.y = 1
	# elif Input.is_action_pressed("up"):
	# 	input_vector.y = -1

	# Normalize the input vector to ensure consistent movement speed
	input_vector = input_vector.normalized()

func _move_character(_delta: float) -> void:
	velocity = input_vector * speed
	move_and_slide()
	


