extends Node2D

class_name Main

## Y value for water surface
const waterLevel : int = 34
## Are birds currently active
var birdsActive = false
## Time last bird activation happened
var lastBirdActivation = 0
## Is currently catching a fish
var catching : bool = false

@onready var fish_caught_screen: Sprite2D = $FishCaughtScreen
@onready var power_bar: PowerBar = $PowerBar
@onready var bucket_screen: Bucket = $BucketScreen
@onready var line: FishingLine = %Line

@onready var clouds = get_node("bg/Clouds")
const SPLASH = preload("res://prefab/animation/splash.tscn")
const FISH_SCENE = preload("res://prefab/menuFish.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Only show title screen and loading screen when not in dev
	if !OS.is_debug_build():
		$titleScreen.show()
		$loadingScreen.show()
	else:
		$titleScreen.queue_free()
		$loadingScreen.queue_free()
	Input.set_custom_mouse_cursor(load("res://art/cursor/pointy.png"), Input.CURSOR_POINTING_HAND)

func start_loading_screen():
	#$loadingScreen.play("default") # will auto play
	# if (randi_range(0, 1000) == 0):
	# 	$player.get_node("Sprite2D").texture = load("res://art/otter/megafrown.png")
	await get_tree().create_timer(2).timeout
	$loadingScreen.queue_free()

func _unhandled_input(event:InputEvent):
	# If the user clicks on the water
	if ((event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) or \
		(event is InputEventKey and event.keycode == KEY_SPACE)) and event.pressed:
		if has_node("loadingScreen"): return
		if fish_caught_screen.visible:
			var fish = fish_caught_screen.get_node("menuFish")
			fish_caught_screen.remove_child(fish)
			$buttons.get_node("Fish").pressed.emit()
			bucket_screen.activeMenuFish = fish
			bucket_screen.add_child(fish)
			bucket_screen.activeMenuFish.z_index = 20
			fish_caught_screen.visible = false
			return
		if event is InputEventKey: return
		## Get the mouse position
		var mousePos = get_global_mouse_position()
		# If the mouse is between 190 and 220
		if mousePos.y < 220 and mousePos.y > 190:
			# If the mouse is between 190 and 220
			if mousePos.x < 256 and mousePos.x > 60:
				# spawn splash sprite
				var splashSprite = SPLASH.instantiate()
				get_parent().add_child(splashSprite)
				# move to mouse position
				splashSprite.position = mousePos
				# z_index = -1

func _process(delta):
	# TODO remove to be self controlled
	bird_anim()
	cloud_anim(delta)


func bird_anim():
	if not birdsActive and (Time.get_ticks_msec() - lastBirdActivation) > 20000:
		lastBirdActivation = Time.get_ticks_msec()
		if randi_range(0, 5) < 3:
			return
		var birds = get_node("bg/BirdSquad/AnimationPlayer")
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
		power_bar.hide()
		$Bait.hide()
	if anim == "panUp":
		power_bar.show()
		$Bait.show()
		catching = false
		line.resetPhases()
		line.lineEnd.hide()
		if $FishSpawner.get_child_count() < 8:
			for i in range(0, 10 - $FishSpawner.get_child_count()):
				$FishSpawner.spawnFish(i + randi_range(0, 10), i + randi_range(0, 10))

func on_reeling(data: FishData):
	catching = true
	get_node("Camera2D/AnimationPlayer").play("panUp")
	power_bar.power = 0
	power_bar.get_node("Mask").size.y = power_bar.top
	power_bar.get_node("Mask/Cap").hide()
	line.get_fish()
	if (data == null):
		return
	
	var fish = FISH_SCENE.instantiate()
	self.add_child(fish)
	fish.populate(data)
	fish.global_position = line.lineEnd.global_position
	var tween = fish.create_tween()
	tween.tween_property(fish, "global_position", Vector2(128 - fish.size.x / 2, 128 - fish.size.y / 2), 1)
	tween.tween_callback(func():
		var pos = fish.global_position
		remove_child(fish)
		fish_caught_screen.add_child(fish)
		fish.global_position = pos
		fish_popup(data)
	)

func fish_popup(data: FishData):
	fish_caught_screen.visible = true
	get_node("buttons").hide()
	fish_caught_screen.get_node("OneName").text = data.name
	fish_caught_screen.get_node("WeightValue").text = str(randi_range(2, 999))
	fish_caught_screen.get_node("RarityValue").text = FishData.Rarity.keys()[data.rarity]
	fish_caught_screen.get_node("Description").text = data.catchText
