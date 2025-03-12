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
 
signal reeling(fish: FishData)

var rod: Curve2D

# globals that dont belong here lol
var waterLevel = 21
var bottomLevel = 150
var rightLevel = 200
var hookOffsetX = 6 # hook offset x
var hookOffsetY = 4 # hook offset y

# 
var easing = Ease.new()

var hookUnderwater = false

# const start and end points
const pt_A1: Vector2 = Vector2(0,0)
const pt_B1: Vector2 = Vector2(27,-13)

const pt_A2: Vector2 = Vector2(-9,-8)
const pt_B2: Vector2 = Vector2(-31,-14)

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

const pt_Bcp1: Vector2 = Vector2(2,-57)
const pt_Bcp2: Vector2 = Vector2(-41,-21)

const pt_Tcp1: Vector2 = Vector2(-27,-34)
const pt_Tcp2: Vector2 = Vector2(26,-30)

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
var castingDistance := 0.0
@onready var maxCastingDistance: float = data.length
var reelMultiplier := 0.99
var reelPhaseMultiplier := 1.03 

var castingPhase := 0

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
var phase5DeltaMultiplier := 0.9  # reeling speed

# the line above the water
var main_line_bez = BezierCurve.new(
	Vector2(0,0), 
	Vector2(0,0), 
	Vector2(0,0), 
	Vector2(0,0),
	lineSteps,
	[ColorSet.colors[16]]
)

# the line below the water
var sub_line_bez = BezierCurve.new(
	Vector2(0,0), 
	Vector2(0,0), 
	Vector2(0,0), 
	Vector2(0,0),
	lineSteps,
	[ColorSet.colors[15]]
)
	
func _draw():
	# draw_circle(Vector2(castingDistance, waterLevel), 5, Color("red"))
	if castingPhase < 5 and castingPhase > 2:	
		draw_bezier(main_line_bez)
		draw_bezier(sub_line_bez)
	if castingPhase == 5:
		var pts = Util.plotLine(path_Bn.points[0].x, path_Bn.points[0].y, lineEnd.position.x - hookOffsetX, lineEnd.position.y)
		drawPoints(pts,Color("white"))

func draw_bezier(bez: BezierCurve, drawOutline: bool = false):
	if drawOutline:
		for i in range(bez.rects.size()):
			var rect = bez.rects[i]
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

func _process(delta):
	var i = 0

	if castingPhase == 0: # idle
		lineEnd.position.x = path_Bn.points[0].x + hookOffsetX
		lineEnd.position.y = path_Bn.points[0].y + hookOffsetY
		# return

	if castingPhase == 2: # casting
		lineEnd.show();
		castingPhase = 3
		var pt_L2 = Vector2(castingDistance, waterLevel)
		pt_Lcp1 = Vector2(castingDistance, pt_Lcp1.y)
		pt_Lcp2 = Vector2(castingDistance, pt_Lcp2.y)
		path_Ln = BezierCurve.new(pt_L1, pt_Lcp1, pt_Lcp2, pt_L2, hookSteps)
		print("Casting Phase 3")


	if castingPhase == 3: # waiting for the line to hit the water
		phase3Ratio = phase3Ratio + (delta * phase3DeltaMultiplier)
		if(phase3Ratio > 1):
			# the line has hit the water... entering phase 4
			phase3Ratio = 0.99
			castingPhase = 4
			pt_W1 = Vector2(castingDistance, waterLevel)
			pt_W2 = Vector2(pt_B1.x, waterLevel)

			# spawn a splish
			var splish = load("res://prefab/animation/splish.tscn").instantiate()
			splish.global_position = pt_W1 - Vector2(0, 5)
			add_child(splish)
			
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
	if castingPhase == 5: # reeling in the line
		phase5Ratio = phase5Ratio + (delta * phase5DeltaMultiplier)
		if phase5Ratio < 10:
			lineEnd.position = lineEnd.position.lerp(Vector2(path_Bn.points[0].x + hookOffsetX, path_Bn.points[0].y + hookOffsetY), phase5Ratio)
		else:
			resetPhases()
		
	queue_redraw()

func resetPhases():
	castingPhase = 0
	phase2Ratio = 0
	phase3Ratio = 0
	phase4Ratio = 0
	phase5Ratio = 0
	castingDistance = 0
	castingTime = 0
	cast = false

func get_fish() -> FishData:
	if hooked == null:
		return null
	hooked.queue_free()
	var fishData = hooked.data
	hooked = null
	return fishData

func reel(amount):
	if castingPhase == 4:
		if amount > 0:
			lineEnd.position.x *= reelMultiplier
			lineEnd.position.y *= reelMultiplier
			phase4Ratio *= reelPhaseMultiplier
			if (lineEnd.position.x < pt_B1.x + hookOffsetX):
				lineEnd.position.x = pt_B1.x + hookOffsetX
			if (lineEnd.position.y <= waterLevel + hookOffsetY):
				castingPhase = 5
				reeling.emit(hooked.data if hooked != null else null)
				#resetPhases()
		elif (lineEnd.position.distance_to(Vector2(0,0)) < data.length):
			if (lineEnd.position.x < rightLevel):
				lineEnd.position.x /= reelMultiplier
			lineEnd.position.y /= reelMultiplier

func drawPoints(p, col):
	for point in p:
		draw_rect(Rect2(point, Vector2(1,1)), col)
