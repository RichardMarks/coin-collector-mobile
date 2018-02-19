from math import sin, cos, PI

const PI_2 = PI * 0.5
const B1 = 0.36363636363636365
const B2 = 0.7272727272727273
const B3 = 0.5454545454545454
const B4 = 0.9090909090909091
const B5 = 0.8181818181818182
const B6 = 0.9545454545454546

type Number* = float

proc linear*(t: Number): Number {.inline.} =
  ## linear interpolation
  ## y = x
  result = t

proc quadIn*(t: Number): Number =
  ## quadratic easing
  ## y = x^2
  result = t * t

proc quadOut*(t: Number): Number =
  ## quadractic easing
  ## y = -x^2 + 2x
  result = -(t * (t - 2))

proc quadInOut*(t: Number): Number =
  ## quadratic easing
  ## t = 0..0.5 -> y = (1/2)((2x)^2)
  ## t = 0.5..1 -> y = -(1/2)((2x-1)*(2x-3) - 1)
  if t < 0.5:
    result = 2 * t * t
  else:
    result = (-2 * t * t) + (4 * t) - 1

proc cubeIn*(t: Number): Number =
  ## cubic easing
  ## y = x^3
  result = t * t * t

proc cubeOut*(t: Number): Number =
  ## cubic easing
  ## y = (x - 1)^3 + 1
  var f = t - 1
  result = f * f * f + 1

proc cubeInOut*(t: Number): Number =
  ## cubic easing
  ## t = 0..0.5 -> y = (1/2)((2x)^3)
  ## t = 0.5..1 -> y = (1/2)((2x-2)^3 + 2)
  if t < 0.5:
    result = 4 * t * t * t
  else:
    var f = ((2 * t) - 2)
    result = 0.5 * f * f * f + 1

proc quartIn*(t: Number): Number =
  ## quartic easing
  ## y = x^4
  result = t * t * t * t

proc quartOut*(t: Number): Number =
  ## quartic easing
  ## y = x^4
  linear(t)

proc quartInOut*(t: Number): Number = linear(t)

proc quintIn*(t: Number): Number =
  ## quintic easing
  linear(t)

proc quintOut*(t: Number): Number = linear(t)

proc quintInOut*(t: Number): Number = linear(t)

proc sineIn*(t: Number): Number =
  ## sine wave easing
  linear(t)

proc sineOut*(t: Number): Number = linear(t)

proc sineInOut*(t: Number): Number = linear(t)

proc circularIn*(t: Number): Number =
  ## circular easing
  linear(t)

proc circularOut*(t: Number): Number = linear(t)

proc circularInOut*(t: Number): Number = linear(t)

proc exponentialIn*(t: Number): Number =
  ## exponential easing
  linear(t)

proc exponentialOut*(t: Number): Number = linear(t)

proc exponentialInOut*(t: Number): Number = linear(t)

proc elasticIn*(t: Number): Number =
  ## exponentially-damped sine wave easing
  linear(t)

proc elasticOut*(t: Number): Number = linear(t)

proc elasticInOut*(t: Number): Number = linear(t)

proc backIn*(t: Number): Number =
  ## overshooting cubic easing
  linear(t)

proc backOut*(t: Number): Number = linear(t)

proc backInOut*(t: Number): Number = linear(t)

proc bounceIn*(t: Number): Number =
  ## exponentially-decaying bounce easing
  linear(t)

proc bounceOut*(t: Number): Number = linear(t)

proc bounceInOut*(t: Number): Number = linear(t)

