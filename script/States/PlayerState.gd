class_name PlayerState extends State

const IDLE = "Idle"
const CHARGING = "Charging"
const CAST = "Cast"
const REELING = "Reeling"
const LETOUT = "Letout"

var player: Player

func _ready():
	await owner.ready
	player = owner as Player
	assert(player != null, "PlayerState state type used only in player scene")
