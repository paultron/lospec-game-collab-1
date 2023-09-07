extends Node

class_name Util
static func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, segments:int):
	var points: Array[Vector2] = []
	for n in range(segments):
		var t = float(n)/(float(n)+1)
		var q0 = p0.lerp(p1, t)
		var q1 = p1.lerp(p2, t)
		var r = q0.lerp(q1, t)
		points.append(r)
	return points
