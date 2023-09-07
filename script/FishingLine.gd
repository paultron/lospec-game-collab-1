extends Node2D

class_name FishingLine
const segmentCount: int = 3
const maxLength = 128
const sagAmount = 50
const lineWidth = 1.5

var segments: Array[Segment] = []
var isLineActive := true
@onready var lineEnd: Node2D = $LineEnd

var hookUnderwater: bool:
	get:
		return lineEnd.global_position.y > 256 - get_node('/root/main').waterLevel
# Called when the node enters the scene tree for the first time.
func _ready():
	#Instantiate segments
	for i in range(segmentCount):
		var segment = load("res://prefab/segment.tscn").instantiate()
		segments.append(segment)
		add_child(segment)

func _draw():
	if isLineActive:
		var points = Util._quadratic_bezier(Vector2(0,0),lerp(Vector2(0,sagAmount),lineEnd.position,0.5),lineEnd.position,segmentCount)
		for i in range(segmentCount - 1):
			var line = Util.makeLine(points[i][0],points[i][1],points[i+1][0],points[i+1][1])
			var color = Color(0, 0, 1) if segments[i].position.y > 256 - get_node('/root/main').waterLevel else Color("#dfcbbf")
			#draw_line(points[i], points[i + 1], color, lineWidth)
			for p in line:
				var ps = PackedVector2Array(p)
				var c = PackedColorArray([color])
				draw_primitive(ps,c,PackedVector2Array())
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
