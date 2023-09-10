extends Node2D

class_name FishingLine
const segmentCount: int = 10
const sagAmount = 50
const lineWidth = 1.5

var segments: Array[Segment] = []
var line: Array[Vector2] = []
var points: Array[Vector2] = []

var hooked: Fish = null

@export var data: LineData
@export var rodData: RodData
@onready var letOut: float = data.length

@onready var lineEnd: Sprite2D = $LineEnd

var hookUnderwater: bool:
	get:
		return lineEnd.global_position.y > 256 - get_node('/root/main').waterLevel
var cast := false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _draw():
	if cast:
		points = Util.quadratic_bezier(Vector2(0,0),lerp(Vector2(0,sagAmount),lineEnd.position,0.5),lineEnd.position,segmentCount)
		for i in range(segmentCount - 1):
			#line = Util.makeLine(points[i].x,points[i].y,points[i+1].x,points[i+1].y)
			var color = Color(0, 0, 1) if segments[i].position.y > 256 - get_node('/root/main').waterLevel else Color("#dfcbbf")
			#draw_line(points[i], points[i + 1], color, lineWidth)
			line = Util.plotLine(points[i].x, points[i].y, points[i + 1].x,points[i + 1].y)
			for p in line:
				#pass
				draw_rect(Rect2(p,Vector2(1,1)),color)
	if !cast:
		pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !cast:
		return
	#Apply gravity to the end position
	if hookUnderwater:
		lineEnd.position.y += delta * 10.0
	else:
		lineEnd.position.y += delta * 100.0
	#clamp line length to the data length
	if hookUnderwater:
		lineEnd.position += sin(Time.get_ticks_msec() / 1000.0) * Vector2(0.1, 0)
	# Update segment x positions to divide the line into equal parts
	var distance = lineEnd.position.distance_to(Vector2(0, 0))
	if distance > int(letOut):
		lineEnd.position = lineEnd.position.normalized() * int(letOut)
	var segmentLength = lineEnd.position.x / segmentCount
	for i in range(segmentCount):
		segments[i].position.x = segmentLength * i
		segments[i].position.y = lineEnd.position.y / segmentCount * i

	queue_redraw()

func reel(amount):
	letOut -= amount * rodData.reelingSpeed
	if letOut < 0:
		cast = false
		for i in segments.size():
			segments[i].queue_free()
		segments.clear()
		letOut = 0
		queue_redraw()
	elif letOut > data.length:
		letOut = data.length

func populate_line():
	for i in range(segmentCount):
		var segment = load("res://prefab/segment.tscn").instantiate()
		segments.append(segment)
		add_child(segment)
