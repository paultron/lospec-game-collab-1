extends Node2D

class_name BezierCurve
# Define the variables
var xy0: Vector2 = Vector2(0,0)
var cp0: Vector2 = Vector2(0,0)
var cp1: Vector2 = Vector2(0,0)
var xy1: Vector2 = Vector2(0,0)

var colors: Array[Color] = []

var steps: int = 8 # number of steps in the bezier
var points: Array[Vector2] = []
var rects: Array[Rect2] = []
var rectStepIdx: Array[int] = []
var sizes: Array[int] = []

func _init(_xy0: Vector2 = Vector2(0,0), _cp0: Vector2 = Vector2(0,0), _cp1: Vector2 = Vector2(0,0), _xy1: Vector2 = Vector2(0,0), _steps: int = 0, _colors: Array[Color] = [], _sizes: Array[int] = []):
	xy0 = _xy0
	cp0 = _cp0
	cp1 = _cp1
	xy1 = _xy1
	steps = _steps
	colors = _colors
	sizes = _sizes
	recalc(xy0,cp0,cp1,xy1)
	
func recalc(_xy0: Vector2, _cp0: Vector2, _cp1: Vector2, _xy1: Vector2):
	points = []
	rects = []
	rectStepIdx = []

	if sizes.size() == 0:
		for i in range(steps):
			sizes.append(1)

	for i in range(steps + 1):
		var t: float = i / float(steps)
		var point: Vector2 = bezier_interp(_xy0, _cp0, _cp1, _xy1, t)
		points.append(point)
		if(i == sizes.size()):
			sizes.append(1)

	
	for i in range(steps):
	
		#draw_line(points[i], points[i + 1], colors[i], 2)
		var line = Util.plotLine(points[i].x, points[i].y, points[i+1].x, points[i+1].y)

		for p in line:
			# if sizes[i] is not null:
			var sz = sizes[i] if sizes[i] != null else sizes[sizes.size()-1]
			rects.append(Rect2(p, Vector2(sz,sz)))
			rectStepIdx.append(i)

# Bezier interpolation function
func bezier_interp(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	var tt: float = t * t
	var uu: float = u * u
	var uuu: float = uu * u
	var ttt: float = tt * t

	var p: Vector2 = uuu * p0
	p += 3 * uu * t * p1
	p += 3 * u * tt * p2
	p += ttt * p3

	return p
