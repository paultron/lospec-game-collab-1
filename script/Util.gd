extends Node

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, segments:int):
	var points: Array[Vector2] = []
	for n in range(segments):
		var t = float(n)/(float(n)+1)
		var q0 = p0.lerp(p1, t)
		var q1 = p1.lerp(p2, t)
		var r = q0.lerp(q1, t)
		points.append(r)
	return points

func makeLine(x0, y0, x1, y1):
	var dx = abs(x1 - x0)
	var sx = 1 if x0 < x1 else -1
	var dy = -abs(y1 - y0)
	var sy = 1 if y0 < y1 else -1
	var error = dx + dy
	
	var points: Array[Vector2] = []
	
	while true:
		points.append(Vector2(x0,y0))
		if x0 == x1 and y0 == y1: break
		var e2 = 2 * error
		if e2 >= dy:
			if x0 == x1: break
			error = error + dy
			x0 = x0 + sx
		#end if
		if e2 <= dx:
			if y0 == y1: break
			error = error + dx
			y0 = y0 + sy
		#end if
	#end while
	return points
