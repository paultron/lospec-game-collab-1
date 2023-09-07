extends Node2D

class_name FishingLine
const segmentCount: int = 10
const maxLength = 128

var segments: Array[Segment] = []
var isLineActive := true
@onready var lineEnd: Node2D = $LineEnd

var hookUnderwater: bool:
	get:
		return lineEnd.global_position.y > 256 - get_tree().root.get_child(0).waterLevel
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
			var color = Color(0, 0, 1) if segments[i].position.y > 256 - get_tree().root.get_child(0).waterLevel else Color("#dfcbbf")
			draw_line(segments[i].position, segments[i + 1].position, color, 1.5)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Apply gravity to the end position
	if hookUnderwater:
		lineEnd.position.y += delta * 10.0
	else:
		lineEnd.position.y += delta * 100.0
	lineEnd.position.y = clamp(lineEnd.position.y, 0, 256)
	if hookUnderwater:
		lineEnd.position += sin(Time.get_ticks_msec() / 1000.0) * Vector2(0.5, 0)
		lineEnd.position.x = clamp(lineEnd.position.x, 0, maxLength)
	# Update segment x positions to divide the line into equal parts
	var segmentLength = lineEnd.position.x / segmentCount
	for i in range(segmentCount):
		segments[i].position.x = segmentLength * i
		segments[i].position.y = lineEnd.position.y / segmentCount * i
	queue_redraw()
	pass
