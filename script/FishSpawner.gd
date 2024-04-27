extends Node2D
class_name FishSpawner

const bottomY: int = 145
var lastSpawned = 0
var lastSpawnedType: FishData.Size

const small_fish: Array = [
	preload("res://data/shrimpo.tres"),
]

const medium_fish: Array = [
	preload("res://data/anglerfish.tres"),
]

const large_fish: Array = [
	preload("res://data/1-bish.tres"),
]

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(0, 15):
		spawnFish(i, i)

func spawnFish(depth_hint: int, x_hint: int = 0):
	# 50 % chance of small, 30 % chance of medium, 20 % chance of large
	var fish: Fish

	var rand = randf()
	if rand < 0.6:
		lastSpawnedType = FishData.Size.SMALL
		fish = load("res://prefab/fish/small.tscn").instantiate()
		fish.data = small_fish[randi() % small_fish.size()]
	elif rand < 0.9:
		lastSpawnedType = FishData.Size.MEDIUM
		fish = load("res://prefab/fish/medium.tscn").instantiate()
		fish.data = medium_fish[randi() % medium_fish.size()]
	else:
		lastSpawnedType = FishData.Size.LARGE
		fish = load("res://prefab/fish/large.tscn").instantiate()
		fish.data = large_fish[randi() % large_fish.size()]
	fish.position = Vector2((256 / 5) * x_hint + randi_range(0, 10), (bottomY / 5) * depth_hint + randi_range(0, 10))
	# Clamp position to at least 48 pixels above the bottom
	fish.position.y = min(fish.position.y, bottomY - 48)
	# Clamp position to at least 48 pixels from the left
	fish.position.x = max(fish.position.x, 48)
	# Clamp position to at least 48 pixels from the right
	fish.position.x = min(fish.position.x, 256 - 48)
	# Clamp position to at least 48 pixels from the top
	fish.position.y = max(fish.position.y, 48)
	add_child(fish)


