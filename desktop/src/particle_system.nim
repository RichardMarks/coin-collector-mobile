import sdl2
import math

proc drawParticle*(renderer: RendererPtr, h,k, radius: float32, color: Color) =
  ## draws a single particle. (h,k) is the center point of the circle-like particle

  let 
    step: float32 = PI * 2 / 20
  var 
    theta: float = 0

  while theta < (PI * 2):
    let 
      x1 = h + radius * cos(theta)
      y1 = k - radius * sin(theta)
      x2 = h - radius * cos(theta)
      y2 = k + radius * sin(theta)
    renderer.drawLine( x1.cint, y1.cint, x2.cint, y2.cint)
    theta += step