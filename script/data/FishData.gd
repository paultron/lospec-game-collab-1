extends Resource
class_name FishData

enum Size {
	SMALL,
	MEDIUM,
	LARGE
}

enum Rarity {
	EPIC,
	RARE,
	COOL,
	OKAY,
	LAME
}

@export var sprite: Texture2D
@export_multiline var hookText: String
@export_multiline var catchText: String
@export var name: String
@export var size: Size
@export var rarity: Rarity = Rarity.LAME
@export var tags: Array[String] = []
