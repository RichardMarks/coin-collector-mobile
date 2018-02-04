# import basic2d
# import strutils
# import times
# import math
# import strfmt
# import streams
# import os

# import sdl2
# import sdl2.image
# import sdl2.ttf

# type
#   SDLException = object of Exception

#   CacheLine = object
#     texture: TexturePtr
#     w, h: cint

#   TextCache = ref object
#     text: string
#     cache: array[2, CacheLine]

#   Input {.pure.} = enum none, left, right, jump, restart, quit, camera

#   Game = ref object
#     inputs: array[Input, bool]
#     inputPressed: array[Input, bool]
#     renderer: RendererPtr
#     font: FontPtr

include game_types

template sdlFailIf(condition: typed, reason: string) =
  if condition:
    raise SDLException.newException(reason & ", SDL Error: " & $getError())

proc newTextCache(): TextCache =
  new result

proc renderText(renderer: RendererPtr, font: FontPtr, text: string, x, y, outline: cint, color: Color): CacheLine =
  font.setFontOutline(outline)
  let surface = font.renderUtf8Blended(text.cstring, color)
  sdlFailIf(surface.isNil):
    "Failed to render text surface: " & text
  discard surface.setSurfaceAlphaMod(color.a)

  result.w = surface.w
  result.h = surface.h
  result.texture = renderer.createTextureFromSurface(surface)

  sdlFailIf(result.texture.isNil):
    "Failed to create texture from rendered text: " & text

  surface.freeSurface()

proc renderText(game: Game, text: string, x, y: cint, color: Color, tc: TextCache) =
  let passes = [
    (color: color(0, 0, 0, 64), outline: 2.cint),
    (color: color, outline: 0.cint)
  ]

  if text != tc.text:
    for i in 0..1:
      tc.cache[i].texture.destroy()
      tc.cache[i] = game.renderer.renderText(game.font, text, x, y, passes[i].outline, passes[i].color)
      tc.text = text
  for i in 0..1:
    var
      source = rect(0, 0, tc.cache[i].w, tc.cache[i].h)
      dest = rect(x - passes[i].outline, y - passes[i].outline, tc.cache[i].w, tc.cache[i].h)
    game.renderer.copyEx(tc.cache[i].texture, source, dest, angle = 0.0, center = nil, flip = SDL_FLIP_NONE)

template renderTextCached(game: Game, text: string, x, y: cint, color: Color) =
  block:
    var tc {.global.} = newTextCache()
    game.renderText(text, x, y, color, tc)

proc newGame(renderer: RendererPtr): Game =
  new result
  result.renderer = renderer
  # result.font = openFontRW(readRW("DejaVuSans.ttf"), freesrc = 1, 24)
  result.font = openFont("DejaVuSans.ttf", 24)
  sdlFailIf(result.font.isNil):
    "Failed to load font"

proc wasPressed(game:Game, input:Input): bool =
  if game.inputs[input]:
    game.inputPressed[input] = true
    result = false
  else:
    if game.inputPressed[input]:
      game.inputPressed[input] = false
      result = true

proc update(game: Game, tick: int) =
  discard

proc toInput(key: Scancode): Input =
  case key
  of SDL_SCANCODE_A: Input.left
  of SDL_SCANCODE_D: Input.right
  of SDL_SCANCODE_LEFT: Input.left
  of SDL_SCANCODE_RIGHT: Input.right
  of SDL_SCANCODE_SPACE: Input.confirm
  of SDL_SCANCODE_UP: Input.up
  of SDL_SCANCODE_DOWN: Input.down
  of SDL_SCANCODE_Q: Input.quit
  of SDL_SCANCODE_ESCAPE: Input.quit
  of SDL_SCANCODE_BACKSPACE: Input.cancel
  of SDL_SCANCODE_RETURN: Input.confirm
  else: Input.none

proc handleInput(game: Game) =
  var event = defaultEvent
  while pollEvent(event):
    case event.kind
    of QuitEvent: game.inputs[Input.quit] = true
    of KeyDown: game.inputs[event.key.keysym.scancode.toInput] = true
    of KeyUp: game.inputs[event.key.keysym.scancode.toInput] = false
    else: discard

proc render(game: Game, tick: int) =
  game.renderer.clear()

  game.renderer.present()

proc main() =
  sdlFailIf(not sdl2.init(INIT_EVERYTHING)):
    "Failed to initialize SDL2"

  defer:
    sdl2.quit()

  sdlFailIf(not sdl2.setHint("SDL_RENDER_SCALE_QUALITY", "2")):
    "Failed to set linear texture filtering"

  sdlFailIf(image.init(image.IMG_INIT_PNG) != image.IMG_INIT_PNG):
    "Failed to initialize SDL2 Image extension"
  defer:
    image.quit()

  sdlFailIf(ttfInit() == SdlError):
    "Failed to initialize SDL2 TTF extension"
  defer:
    ttfQuit()

  let window = sdl2.createWindow(
    title = "Coin Collector - Desktop Alpha",
    x = SDL_WINDOWPOS_CENTERED,
    y = SDL_WINDOWPOS_CENTERED,
    w = 1280,
    h = 720,
    flags = SDL_WINDOW_SHOWN)
  sdlFailIf(window.isNil):
    "Failed to create window"
  defer:
    window.destroy()

  let renderer = window.createRenderer(
    index = -1,
    flags = sdl2.Renderer_Accelerated or sdl2.Renderer_PresentVsync)
  sdlFailIf(renderer.isNil):
    "Failed to create renderer"
  defer:
    renderer.destroy()

  renderer.setDrawColor(r = 0xFF, g = 0x00, b = 0xFF)

  # var lmb:bool = false

  var
    game = newGame(renderer)
    startTime = epochTime()
    lastTick = 0

  while not game.inputs[Input.quit]:
    game.handleInput()
    let newTick = int((epochTime() - startTime) * 50)
    for tick in lastTick+1..newTick:
      game.update(tick)
    lastTick = newTick
    game.render(lastTick)

when isMainModule:
  main()

  # var masterEvent: sdl2.Event = sdl2.defaultEvent
  # var isRunning: bool = true
  # while isRunning:
  #   while sdl2.pollEvent(masterEvent):
  #     case masterEvent.kind:
  #       of sdl2.QuitEvent: isRunning = false
  #       of sdl2.KeyDown:
  #         if masterEvent.key.keysym.sym == sdl2.K_ESCAPE:
  #           isRunning = false
  #       else: discard
  #   # grab mouse state
  #   # if LMB is down, print mouse position to console
  #   var mouseX: cint = 0
  #   var mouseY: cint = 0
  #   if sdl2.SDL_BUTTON(sdl2.getMouseState(mouseX, mouseY)) == sdl2.BUTTON_LEFT:
  #     if lmb == false:
  #       lmb = true
  #   else:
  #     if lmb:
  #       lmb = false
  #       stdout.write("mouse clicked at ", $mouseX, ",", $mouseY, char(0xa))

  #   renderer.clear()
  #   renderer.present()
