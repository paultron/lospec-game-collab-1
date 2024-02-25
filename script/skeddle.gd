extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var state: State = State.idle
var lastStateChange = 0

enum State { idle, swimLeft, swimRight, upset }

func _ready():
	sprite.play("idle")
	area_entered.connect(func(body: Node): 
		if body.get_parent() is splash:
			state = State.upset
			sprite.offset = Vector2(0, -16)
			sprite.play("upset")
	)
	pass 

func _process(delta):
	if state == State.swimLeft:
		position.x = max(position.x - 10 * delta, 64)
	elif state == State.swimRight:
		position.x = min(position.x + 10 * delta, 220)
	# Every 3 seconds, 50% chance of changing state
	if randf() < 0.5 and Time.get_ticks_msec() - lastStateChange > 3000:
		lastStateChange = Time.get_ticks_msec()
		match state:
			State.idle:
				if randf() < 0.5 && position.x > 60:
					state = State.swimLeft
					sprite.flip_h = true
					$fart.flip_h = true
					$fart.position.x = 14
					sprite.play("move")
				elif randf() < 0.5 && position.x < 180:
					state = State.swimRight
					sprite.flip_h = false
					$fart.flip_h = false
					$fart.position.x = -7
					sprite.play("move")
				elif randf() < 0.1:
					fart()
			State.swimLeft:
				state = State.idle
				sprite.play("idle")
			State.swimRight:
				state = State.idle
				sprite.play("idle")
			State.upset:
				sprite.animation_looped.connect(func(): 
					sprite.offset = Vector2(0, 0)
					state = State.idle
					sprite.play("idle")
				)


func fart():
	$fart.play("default")
