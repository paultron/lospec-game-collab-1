extends Node2D

class_name FishingLine
const segmentCount: int = 10
const maxLength = 128

var segments: Array[Segment] = []
var isLineActive := true
var endPosition: Vector2 = Vector2(maxLength - 24, 10)

var hookUnderwater: bool:
	get:
		return position.y + endPosition.y > get_tree().root.get_child(0).waterLevel
# Called when the node enters the scene tree for the first time.
func _ready():
	#Instantiate segments
	for i in range(segmentCount):
		var segment = load("res://prefab/segment.tscn").instantiate()
		segments.append(segment)
		add_child(segment)

func _draw():
	if isLineActive:
		for i in range(segmentCount - 1):
			draw_line(segments[i].position, segments[i + 1].position, Color(1, 1, 1), 1.5)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Apply gravity to the end position
	if hookUnderwater:
		endPosition.y += delta * 10.0
	else:
		endPosition.y += delta * 100.0
	endPosition.y = clamp(endPosition.y, 0, 256)
	if hookUnderwater:
		endPosition += sin(Time.get_ticks_msec() / 1000.0) * Vector2(0.5, 0)
	endPosition.x = clamp(endPosition.x, 0, maxLength)
	# Update segment x positions to divide the line into equal parts
	var segmentLength = endPosition.x / segmentCount
	for i in range(segmentCount):
		segments[i].position.x = segmentLength * i
		segments[i].position.y = endPosition.y / segmentCount * i
	queue_redraw()
	pass
