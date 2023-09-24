extends Node2D

const waterLevel: int = 34
var birdsActive = false
var lastBirdActivation = 0

@onready var clouds = $bg.get_node("clouds")

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(load("res://art/cursor/pointy.png"), Input.CURSOR_POINTING_HAND)
	$loadingScreen.play("default")
	# if (randi_range(0, 1000) == 0):
	# 	$player.get_node("Sprite2D").texture = load("res://art/otter/megafrown.png")
	# wait 3 seconds
	await get_tree().create_timer(3).timeout
	$loadingScreen.queue_free()

func _unhandled_input(event):
	# If the user clicks on the water
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Get the mouse position
		var mousePos = get_global_mouse_position()
		# If the mouse is between 190 and 220
		if mousePos.y < 220 and mousePos.y > 190:
			# If the mouse is between 190 and 220
			if mousePos.x < 256 and mousePos.x > 60:
				# spawn splash sprite
				var splash = load("res://prefab/splash.tscn").instantiate()
				get_parent().add_child(splash)
				# move to mouse position
				splash.position = mousePos
				z_index = -1

func _process(delta):
	bird_anim()
	cloud_anim(delta)


func bird_anim():
	if not birdsActive and Time.get_ticks_msec() - lastBirdActivation > 20000:
		lastBirdActivation = Time.get_ticks_msec()
		if randi_range(0, 5) < 3:
			return
		var birds = $bg.get_node("BirdSquad/AnimationPlayer")
		for bird in birds.get_parent().get_children():
			if bird is AnimatedSprite2D:
				bird.frame = randi_range(0, 4)
				bird.play("default")
		birds.play("move")
		birdsActive = true
		birds.animation_finished.connect(
			func(_animation):
				birds.stop()
				birdsActive = false
				for bird in birds.get_parent().get_children():
					if bird is AnimatedSprite2D:
						bird.stop()
		)

func cloud_anim(delta: float):
	clouds.position.x -= delta * 10
	if clouds.position.x <= -768:
		clouds.position.x = 0

func on_cast():
	pass

func on_pan_finish(anim):
	if anim == "pan":
		$Power.hide()
		$Bait.hide()
	if anim == "panUp":
		$Power.show()
		$Bait.show()
			

