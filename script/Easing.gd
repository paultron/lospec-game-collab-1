extends Node2D

class_name Ease

func inQuad(x):
	return x * x

func inCubic(x):
	return x * x * x

func inQuart(x):
	return x * x * x * x

func inQuint(x):
	return x * x * x * x * x

func outQuad(x):
	return 1 - (1 - x) * (1 - x)

func outSine(x):
	return sin(x * PI / 2)

func outCubic(x):
	return 1 - pow(1 - x, 3)

func outQuart(x):
	return 1 - pow(1 - x, 4)

func outQuint(x):
	return 1 - pow(1 - x, 5)

func inSine(x):
	return 1 - cos(x * PI / 2)

func inOutSine(x):
	return -(cos(PI * x) - 1) / 2

func inCirc(x):
	return 1 - sqrt(1 - pow(x, 2))

func outCirc(x):
	return sqrt(1 - pow(x - 1, 2))

func inExpo(x):
	return 0 if x == 0 else pow(2, 10 * x - 10)

func outExpo(x):
	return 1 if x == 1 else 1 - pow(2, -10 * x)

func inOutQuad(x):
	return 2 * x * x if x < 0.5 else 1 - pow(-2 * x + 2, 2) / 2

func inOutCubic(x):
	return 4 * x * x * x if x < 0.5 else 1 - pow(-2 * x + 2, 3) / 2

func inBack(x):
	var c1 = 1.70158
	var c3 = c1 + 1
	return c3 * x * x * x - c1 * x * x

func inOutQuart(x):
	return 8 * x * x * x * x  if x < 0.5 else 1 - pow(-2 * x + 2, 4) / 2

func inOutQuint(x):
	return 16 * x * x * x * x * x if x < 0.5 else 1 - pow(-2 * x + 2, 5) / 2

func outBack(x):
	var c1 = 1.70158
	var c3 = c1 + 1
	return 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2)

func inOutExpo(x):
	return 0 if x == 0 else 1 if x == 1 else pow(2, 20 * x - 10) / 2 if x < 0.5 else (2 - pow(2, -20 * x + 10)) / 2

func inOutCirc(x):
	return (1 - sqrt(1 - pow(2 * x, 2))) / 2 if x < 0.5 else (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2

func outElastic(x):
	var c4 = (2 * PI) / 3
	return 0 if x == 0 else 1 if x == 1 else pow(2, -10 * x) * sin((x * 10 - 0.75) * c4) + 1

func inElastic(x):
	var c4 = (2 * PI) / 3
	return 0 if x == 0 else 1 if x == 1 else -pow(2, 10 * x - 10) * sin((x * 10 - 10.75) * c4)

func inOutBack(x):
	var c1 = 1.70158
	var c2 = c1 * 1.525
	x *= 2
	if x < 1:
		return (x * x * ((c2 + 1) * x - c2)) / 2
	else:
		x -= 2
		return (x * x * ((c2 + 1) * x + c2) + 2) / 2

func inOutElastic(x):
	var c5 = (2 * PI) / 4.5
	if x == 0:
		return 0
	x *= 2
	if x == 2:
		return 1
	if x < 1:
		return -0.5 * pow(2, 10 * x - 10) * sin((x * 10 - 10.75) * c5)
	else:
		return 0.5 * pow(2, -10 * x + 10) * sin((x * 10 - 10.75) * c5) + 1

func outBounce(x):
	var n1 = 7.5625
	var d1 = 2.75
	if x < 1 / d1:
		return n1 * x * x
	elif x < 2 / d1:
		x -= 1.5 / d1
		return n1 * x * x + 0.75
	elif x < 2.5 / d1:
		x -= 2.25 / d1
		return n1 * x * x + 0.9375
	else:
		x -= 2.625 / d1
		return n1 * x * x + 0.984375

func inBounce(x):
	return 1 - outBounce(1 - x)

func inOutBounce(x):
	if x < 0.5:
		return (1 - outBounce(1 - 2 * x)) / 2
	else:
		return (1 + outBounce(2 * x - 1)) / 2
