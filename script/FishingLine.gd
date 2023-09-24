extends Node2D

class_name FishingLine
const segmentCount: int = 10
const sagAmount = 50
const lineWidth = 1.5

# preload("res://script/Bezier.gd") var Bezier = load("res://script/Bezier.gd")

var line: Array[Vector2] = []
var points: Array[Vector2] = []

var hooked: Fish = null

@export var data: LineData
@export var rodData: RodData
@onready var letOut: float = data.length

@onready var lineEnd: Sprite2D = $LineEnd

var rod: Curve2D

# globals that dont belong here lol
var waterLevel = 21
var bottomLevel = 150
var hookOffsetX = 6 # hook offset x
var hookOffsetY = 4 # hook offset y

# 
var easing = Ease.new()

var hookUnderwater = false

# static start and end points
var pt_A1: Vector2 = Vector2(0,0)
var pt_B1: Vector2 = Vector2(24,-24)

var pt_A2: Vector2 = Vector2(-9,-8)
var pt_B2: Vector2 = Vector2(-31,-14)

var pt_L1: Vector2 = pt_B1

var pt_T1: Vector2 = Vector2(-23,-33)
var pt_T2: Vector2 = Vector2(26,-30)

var pt_W1: Vector2 = Vector2(0,0)
var pt_W2: Vector2 = Vector2(0,0)

var pt_S1: Vector2 = Vector2(0,0)
var pt_S2: Vector2 = Vector2(0,0)


# static control points
var pt_Acp1: Vector2 = Vector2(pt_A1.x,pt_A2.y)
var pt_Acp2: Vector2 = Vector2(pt_A1.x,pt_A2.y)

var pt_Bcp1: Vector2 = Vector2(2,-57)
var pt_Bcp2: Vector2 = Vector2(-41,-21)

var pt_Tcp1: Vector2 = Vector2(-27,-34)
var pt_Tcp2: Vector2 = Vector2(26,-30)

var pt_Lcp1: Vector2 = Vector2(92,-45)
var pt_Lcp2: Vector2 = Vector2(104,-16)

var pt_Scp1: Vector2 = Vector2(0,0)
var pt_Scp2: Vector2 = Vector2(0,0)

var pt_Wcp1: Vector2 = Vector2(0,0)
var pt_Wcp2: Vector2 = Vector2(0,0)

var phaseSteps = 64
var lineSteps = 200
var hookSteps = 200

# static paths
var path_An = BezierCurve.new(pt_A1, pt_Acp1, pt_Acp2, pt_A2, phaseSteps)
var path_Bn = BezierCurve.new(pt_B1, pt_Bcp1, pt_Bcp2, pt_B2, phaseSteps)
var path_Tn = BezierCurve.new(pt_T1, pt_Tcp1, pt_Tcp2, pt_T2, phaseSteps)

var path_Ln = BezierCurve.new(
	Vector2(0,0), 
	Vector2(0,0), 
	Vector2(0,0), 
	Vector2(0,0),
	lineSteps
)
var path_Sn = BezierCurve.new(
	Vector2(0,0), 
	Vector2(0,0), 
	Vector2(0,0), 
	Vector2(0,0),
	lineSteps
)
var path_Wn = BezierCurve.new(
	Vector2(0,0), 
	Vector2(0,0), 
	Vector2(0,0), 
	Vector2(0,0),
	lineSteps
)

var cast := false
var castingTime := 0.0
var castingRatio := 0.0
var maxCastingTime := 3.0
var castingDistance := 0.0
var maxCastingDistance := 200.0
var reelMultiplier := 0.99
var reelPhaseMultiplier := 1.03 

var castingPhase := 0

# phase 1 - charging up
var phase1Ratio := 0.0
var phase1DeltaMultiplier := 0.6 # charging speed

# phase 2 - casting
var phase2Ratio := 0.0
var phase2DeltaMultiplier := 1.7 # flinging speed

# phase 3 - hook flying through the air
var phase3Ratio := 0.0
var phase3DeltaMultiplier := 0.9 # flight speed

# phase 4 - hook sinking to the bottom
var phase4Ratio := 0.0
var phase4DeltaMultiplier := 0.03 # sinking speed

# phase 5 - reeling in the fish (or the hook)
var phase5Ratio := 0.0
var phase5DeltaMultiplier := 0.9 # reeling speed

# the fishing rod
var avg_pt = Vector2(
	(path_An.points[0].x + path_Bn.points[0].x) / 2, 
	(path_An.points[0].y + path_Bn.points[0].y) / 2
)

# the line above the water
var main_line_bez = BezierCurve.new(
	Vector2(0,0), 
	Vector2(0,0), 
	Vector2(0,0), 
	Vector2(0,0),
	lineSteps,
	[ColorPalette.colors[16]]
)

# the line below the water
var sub_line_bez = BezierCurve.new(
	Vector2(0,0), 
	Vector2(0,0), 
	Vector2(0,0), 
	Vector2(0,0),
	lineSteps,
	[ColorPalette.colors[15]]
)
	
func _draw():
	if castingPhase > 2:	
		draw_bezier(main_line_bez)
		draw_bezier(sub_line_bez)

func draw_bezier(bez: BezierCurve, drawOutline: bool = false):
	if drawOutline:
		for i in range(bez.rects.size()):
			var rect = bez.rects[i]
			#print(rect)
			#var rectStepIdx = bez.rectStepIdx[i]
			#var rectColor = bez.colors[rectStepIdx]
			var pt2 = Vector2(
				rect.position.x - 1,
				rect.position.y
			)
			var sz2 = Vector2(
				rect.size.x + 2,
				rect.size.y
			)
			var rect2 = Rect2(pt2, sz2)
			draw_rect(rect2, Color(0,0,0,1))
		
		# draw left and right 
		for i in range(bez.rects.size()):
			var rect = bez.rects[i]
			#print(rect)
			#var rectStepIdx = bez.rectStepIdx[i]
			#var rectColor = bez.colors[rectStepIdx]
			var pt2 = Vector2(
				rect.position.x,
				rect.position.y - 1
			)
			var sz2 = Vector2(
				rect.size.x,
				rect.size.y + 2
			)
			var rect2 = Rect2(pt2, sz2)
			draw_rect(rect2, Color(0,0,0,1))

	for i in range(bez.rects.size()):
		var rect = bez.rects[i]
		var rectStepIdx = bez.rectStepIdx[i]
		var rectColor = bez.colors[rectStepIdx % bez.colors.size()]
		draw_rect(rect, rectColor)

func applyCastPower(ratio: float):
	phase2Ratio = 1 - ratio
	castingPhase = 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if !cast:
		#return

	var i = 0

	if castingPhase == 0: # idle
		lineEnd.position.x = path_Bn.points[0].x + hookOffsetX
		lineEnd.position.y = path_Bn.points[0].y + hookOffsetY
		# return

	if castingPhase == 1: # powering up the cast
		phase1Ratio = phase1Ratio + (delta * phase1DeltaMultiplier)
		#print(phase1Ratio)
		if(phase1Ratio > 1):
			# finished powering up... entering phase 2
			phase1Ratio = 0
			castingPhase = 2
			print("Casting Phase 2")
		#print(phase1Ratio)
		var b1n_size = path_Bn.points.size() - 1
		#print(b1n_size)
		i = int(easing.inQuad(phase1Ratio) * b1n_size)
		#print("phase1Ratio: [" + str(i) + "]" + str(phase1Ratio))
		# lineEnd.position.x = path_Bn.points[i].x + hookOffsetX
		# lineEnd.position.y = path_Bn.points[i].y + hookOffsetY

	if castingPhase == 2: # casting
		phase2Ratio = phase2Ratio + (delta * phase2DeltaMultiplier)
		if(phase2Ratio > 1):
			# finished casting... entering phase 3
			phase2Ratio = 0
			castingPhase = 3
			var pt_L2 = Vector2(castingDistance, waterLevel)
			pt_Lcp1 = Vector2(castingDistance, pt_Lcp1.y)
			pt_Lcp2 = Vector2(castingDistance, pt_Lcp2.y)
			#print("will hit the water at: "+str(pt_L2))
			path_Ln = BezierCurve.new(pt_L1, pt_Lcp1, pt_Lcp2, pt_L2, hookSteps)
			print("Casting Phase 3")
		#i = int(Easing[phase2Easing](1 - phase2Ratio) * path_Bn.points.size())
		var b1n_size = path_Bn.points.size() - 1
		i = int(clamp(easing.inQuad(1 - phase2Ratio),0,1.0) * b1n_size)
		#print("phase2Ratio: [" + str(i) + "]" + str(phase2Ratio))
		lineEnd.position.x = path_Bn.points[i].x + hookOffsetX
		lineEnd.position.y = path_Bn.points[i].y + hookOffsetY

	if castingPhase == 3: # waiting for the line to hit the water
		phase3Ratio = phase3Ratio + (delta * phase3DeltaMultiplier)
		if(phase3Ratio > 1):
			# the line has hit the water... entering phase 4
			phase3Ratio = 0.99
			castingPhase = 4
			pt_W1 = Vector2(castingDistance, waterLevel)
			pt_W2 = Vector2(pt_B1.x, waterLevel)
			
			var avgX = (pt_B1.x + pt_W1.x) / 2
			var avgPt = Vector2(avgX, waterLevel)
			path_Sn = BezierCurve.new(pt_W1, pt_Scp1, pt_Scp2, pt_S1, hookSteps)
			path_Wn = BezierCurve.new(pt_W1, avgPt, avgPt, pt_W2, hookSteps)
			print("Casting Phase 4")

		var sz = path_Ln.points.size()-1
		i = int(phase3Ratio * sz)
		
		lineEnd.position.x = path_Ln.points[i].x + hookOffsetX
		lineEnd.position.y = path_Ln.points[i].y + hookOffsetY
		pt_Lcp1 = Vector2(
			lerp(pt_B1.x, path_Ln.points[sz-i].x, phase3Ratio),
			lerp(pt_B1.y, path_Ln.points[sz-i].y, phase3Ratio)
		)
		main_line_bez.recalc(
			path_Ln.points[0],
			pt_Lcp1,
			pt_Lcp1,
			path_Ln.points[i]
		)

	if castingPhase == 4: # waiting for the fish to bite

		phase4Ratio = phase4Ratio + (delta * phase4DeltaMultiplier)
		if phase4Ratio > 1:
			phase4Ratio = 0.99
		hookUnderwater = true
		
		if (lineEnd.position.distance_to(Vector2(0,0)) < data.length):
			lineEnd.position.y += delta * 10.0
		if (lineEnd.position.y > bottomLevel):
			lineEnd.position.y = bottomLevel

		var sz = path_Sn.points.size()-1
		i = int(phase4Ratio * sz)

		var pt_W = path_Wn.points[i % path_Wn.points.size()]

		var avgX = (pt_B1.x + pt_W1.x) / 2
		var avgY = (pt_B1.y + pt_W1.y) / 2
		var avgPt = Vector2(avgX, avgY)

		
		var subAvgX = (pt_W.x + lineEnd.position.x) / 2
		var subAvgY = (pt_W.y + lineEnd.position.y) / 2
		var subAvgPt = Vector2(subAvgX, subAvgY)

		pt_Scp1 = Vector2(
			pt_W.x,
			bottomLevel
		)
		pt_Scp2 = pt_Scp1 # TODO: tween this over time

		var pt_hook = Vector2(
			lineEnd.position.x - 6,
			lineEnd.position.y - 5
		)
		path_Ln.recalc(
			pt_B1,
			avgPt, # TODO: tween this over time
			avgPt, # TODO: tween this over time
			pt_W
		)
		path_Sn.recalc(
			pt_W,
			pt_Scp1, # TODO: tween this over time
			pt_Scp2, # TODO: tween this over time
			pt_hook
		)
		pt_Lcp2 = Vector2(
			pt_B1.x,
			waterLevel
		)
		main_line_bez.recalc(
			pt_B1,
			pt_Lcp2, # TODO: tween this over time
			pt_Lcp2, # TODO: tween this over time
			pt_W
		)
		sub_line_bez.recalc(
			pt_W,
			subAvgPt, # TODO: tween this over time
			subAvgPt, # TODO: tween this over time
			pt_hook
		)

	queue_redraw()

func resetPhases():
	castingPhase = 0
	phase1Ratio = 0
	phase2Ratio = 0
	phase3Ratio = 0
	phase4Ratio = 0
	phase5Ratio = 0
	castingDistance = 0
	castingTime = 0
	cast = false

func reel(amount):
	if amount > 0:
		lineEnd.position.x *= reelMultiplier
		lineEnd.position.y *= reelMultiplier
		phase4Ratio *= reelPhaseMultiplier
		if lineEnd.position.x < pt_B1.x + hookOffsetX:
			lineEnd.position.x = pt_B1.x + hookOffsetX
		if lineEnd.position.y < waterLevel + hookOffsetY:
			print("hook is above water... resetting")
			resetPhases()
	elif (lineEnd.position.distance_to(Vector2(0,0)) < data.length):
		lineEnd.position.x /= reelMultiplier
		lineEnd.position.y /= reelMultiplier
