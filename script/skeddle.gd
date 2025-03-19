extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var state: SkedState = SkedState.idle
var lastStateChange = 0

enum SkedState { idle, swimLeft, swimRight, upset }

func _ready():
	sprite.play("idle")
	area_entered.connect(func(body: Node): 
		if body.get_parent() is splash:
			state = SkedState.upset
			sprite.offset = Vector2(0, -16)
			sprite.play("upset")
	)
	pass 

func _process(delta):
	if state == SkedState.swimLeft:
		position.x = max(position.x - 10 * delta, 64)
	elif state == SkedState.swimRight:
		position.x = min(position.x + 10 * delta, 220)
	# Every 3 seconds, 50% chance of changing state
	if randf() < 0.5 and Time.get_ticks_msec() - lastStateChange > 3000:
		lastStateChange = Time.get_ticks_msec()
		match state:
			SkedState.idle:
				if randf() < 0.5 && position.x > 60:
					state = SkedState.swimLeft
					sprite.flip_h = true
					$fart.flip_h = false
					$fart.position.x = 14
					sprite.play("move")
				elif randf() < 0.5 && position.x < 180:
					state = SkedState.swimRight
					sprite.flip_h = false
					$fart.flip_h = true
					$fart.position.x = -7
					sprite.play("move")
				elif randf() > 0.99:
					fart()
				elif randf() > 0.95:
					quack()
			SkedState.swimLeft:
				state = SkedState.idle
				sprite.play("idle")
			SkedState.swimRight:
				state = SkedState.idle
				sprite.play("idle")
			SkedState.upset:
				sprite.animation_looped.connect(func(): 
					sprite.offset = Vector2(0, 0)
					state = SkedState.idle
					sprite.play("idle")
				)


func fart():
	$fart.play("default")

func quack():
	$quack.play()
