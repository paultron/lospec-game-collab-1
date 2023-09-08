extends Node2D

func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, segments:int):
	var points: Array[Vector2] = []
	for n in range(segments):
		var t = float(n)/(float(n)+1)
		var q0 = p0.lerp(p1, t)
		var q1 = p1.lerp(p2, t)
		var r = q0.lerp(q1, t)
		points.append(r)
	return points

func makeLineV0(x0, y0, x1, y1):
	var dx = abs(x1 - x0)
	var sx = 1 if x0 < x1 else -1
	var dy = -abs(y1 - y0)
	var sy = 1 if y0 < y1 else -1
	var error = dx + dy
	var e2 = 0
	var points: Array[Vector2] = []
	var _length = 127
	while true:
		points.append(Vector2(x0,y0))
		if x0 == x1 and y0 == y1:
			break
		e2 = 2 * error
		if e2 >= dy:
			if x0 == x1:
				break
			error = error + dy
			x0 = x0 + sx
		#end if
		if e2 <= dx:
			if y0 == y1:
				break
			error = error + dx
			y0 = y0 + sy
		#end if
		_length -= 1
	#end while
	return points

func plotLineLow(p, x0, y0, x1, y1):
	var dx = x1 - x0
	var dy = y1 - y0
	var yi = 1
	if dy < 0:
		yi = -1
		dy = -dy
	#end if
	var D = (2 * dy) - dx
	var y = y0

	for x in range(x0,x1+1):
		p.append(Vector2(x,y))
		#plot(x, y)
		if D > 0:
			y = y + yi
			D = D + (2 * (dy - dx))
		else:
			D = D + 2*dy
		#end if

func plotLineHigh(p, x0, y0, x1, y1):
	var dx = x1 - x0
	var dy = y1 - y0
	var xi = 1
	if dx < 0:
		xi = -1
		dx = -dx
	#end if
	var D = (2 * dx) - dy
	var x = x0

	for y in range(y0,y1+1):
		#plot(x, y)
		p.append(Vector2(x,y))
		if D > 0:
			x = x + xi
			D = D + (2 * (dx - dy))
		else:
			D = D + 2*dx
		#end if
		
func plotLine(x0, y0, x1, y1):
	var pts: Array[Vector2] = []
	if (abs(y1 - y0) < abs(x1 - x0)):
		if x0 > x1:
			plotLineLow(pts, x1, y1, x0, y0)
		else:
			plotLineLow(pts, x0, y0, x1, y1)
		#end if
	else:
		if y0 > y1:
			plotLineHigh(pts, x1, y1, x0, y0)
		else:
			plotLineHigh(pts, x0, y0, x1, y1)
		#end if
	#end if
	#drawPoints(pts,col)
	return pts
	
func drawPoints(p,col):
	for point in p:
		draw_rect(Rect2(point,Vector2(1,1)),col)
