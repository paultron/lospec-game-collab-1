extends Node2D

class_name Main

const waterLevel: int = 34
var birdsActive = false
var lastBirdActivation = 0
var catching := false

@onready var clouds = $bg.get_node("clouds")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Only show title screen and loading screen when not in dev
	if OS.get_name() == "HTML5":
		$titleScreen.show()
		$loadingScreen.show()
	else:
		$titleScreen.queue_free()
		$loadingScreen.queue_free()
	Input.set_custom_mouse_cursor(load("res://art/cursor/pointy.png"), Input.CURSOR_POINTING_HAND)

func start_loading_screen():
	$loadingScreen.play("default")
	# if (randi_range(0, 1000) == 0):
	# 	$player.get_node("Sprite2D").texture = load("res://art/otter/megafrown.png")
	await get_tree().create_timer(2).timeout
	$loadingScreen.queue_free()

func _unhandled_input(event):
	# If the user clicks on the water
	if ((event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) or \
		(event is InputEventKey and event.keycode == KEY_SPACE)) and event.pressed:
		if has_node("loadingScreen"): return
		if $FishCaught.visible:
			var fish = $FishCaught.get_node("menuFish")
			$FishCaught.remove_child(fish)
			$buttons.get_node("Fish").pressed.emit()
			$Bucket.activeMenuFish = fish
			$Bucket.add_child(fish)
			$Bucket.activeMenuFish.z_index = 20
			$FishCaught.visible = false
			return
		if event is InputEventKey: return
		# Get the mouse position
		var mousePos = get_global_mouse_position()
		# If the mouse is between 190 and 220
		if mousePos.y < 220 and mousePos.y > 190:
			# If the mouse is between 190 and 220
			if mousePos.x < 256 and mousePos.x > 60:
				# spawn splash sprite
				var splashSprite = load("res://prefab/animation/splash.tscn").instantiate()
				get_parent().add_child(splashSprite)
				# move to mouse position
				splashSprite.position = mousePos
				z_index = -1

func _process(delta):
	bird_anim()
	cloud_anim(delta)


func bird_anim():
	if not birdsActive and (Time.get_ticks_msec() - lastBirdActivation) > 20000:
		lastBirdActivation = Time.get_ticks_msec()
		if randi_range(0, 5) < 3:
			return
		var birds = $bg.get_node("BirdSquad/AnimationPlayer")
		for bird in birds.get_parent().get_children():
			if bird is AnimatedSprite2D:
				bird.frame = randi_range(0, 4)
				bird.play("default")
		birds.get_parent().visible = true
		birds.play("move")
		birdsActive = true
		birds.animation_finished.connect(
			func(_animation):
				birds.stop()
				birds.get_parent().visible = false
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
		catching = false
		$player.get_node("Line").resetPhases()
		$player.get_node("Line").lineEnd.hide()
		if $FishSpawner.get_child_count() < 8:
			for i in range(0, 10 - $FishSpawner.get_child_count()):
				$FishSpawner.spawnFish(i + randi_range(0, 10), i + randi_range(0, 10))
func on_reeling(data: FishData):
	catching = true
	get_node("Camera2D/AnimationPlayer").play("panUp")
	$Power.power = 0
	$Power.get_node("Mask").size.y = $Power.top
	$Power.get_node("Mask/Cap").hide()
	$player.get_node("Line").get_fish()
	if (data == null):
		return
	
	var fish = load("res://prefab/menuFish.tscn").instantiate()
	self.add_child(fish)
	fish.populate(data)
	fish.global_position = $player.get_node("Line").lineEnd.global_position
	var tween = fish.create_tween()
	tween.tween_property(fish, "global_position", Vector2(128 - fish.size.x / 2, 128 - fish.size.y / 2), 1)
	tween.tween_callback(func():
		var pos = fish.global_position
		remove_child(fish)
		$FishCaught.add_child(fish)
		fish.global_position = pos
		fish_popup(data)
	)

func fish_popup(data: FishData):
	$FishCaught.visible = true
	get_node("buttons").hide()
	$FishCaught.get_node("OneName").text = data.name
	$FishCaught.get_node("WeightValue").text = str(randi_range(2, 999))
	$FishCaught.get_node("RarityValue").text = FishData.Rarity.keys()[data.rarity]
	$FishCaught.get_node("Description").text = data.catchText
