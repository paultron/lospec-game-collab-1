extends AnimatedSprite2D

class_name splash
# Called when the node enters the scene tree for the first time.
func _ready():
	animation_finished.connect(queue_free)
	#play("default")
