extends Node2D
class_name FishSpawner

const bottomY: int = 145
var lastSpawned = 0
var lastSpawnedType: FishData.Size

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(0, 10):
		spawnFish(i, i)

func spawnFish(depth_hint: int, x_hint: int = 0):
	# 50 % chance of small, 30 % chance of medium, 20 % chance of large
	var fish: Fish

	var rand = randf()
	if rand < 0.7:
		lastSpawnedType = FishData.Size.SMALL
		fish = load("res://prefab/fish/small.tscn").instantiate()
		fish.data = load("res://data/shrimpo.tres")
	elif rand < 0.9:
		lastSpawnedType = FishData.Size.MEDIUM
		fish = load("res://prefab/fish/medium.tscn").instantiate()
		fish.data = load("res://data/shrimpo.tres")
	else:
		lastSpawnedType = FishData.Size.LARGE
		fish = load("res://prefab/fish/large.tscn").instantiate()
		fish.data = load("res://data/shrimpo.tres")
	fish.position = Vector2((256 / 10) * x_hint + randi_range(0, 10), (bottomY / 10 ) * depth_hint + randi_range(0, 10))
	# Clamp position to at least 48 pixels above the bottom
	fish.position.y = min(fish.position.y, bottomY - 48)
	add_child(fish)


