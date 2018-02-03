import basic2d
import strutils
import times
import math
import strfmt

import sdl2
import sdl2.image
import sdl2.ttf

type SDLException = object of Exception

template sdlFailIf(condition: typed, reason: string) =
  if condition:
    raise SDLException.newException(reason & ", SDL Error" & $getError())

proc formatTime(ticks: int): string =
  let
    mins = (ticks div 50) div 60
    secs = (ticks div 50) mod 60
    cents = (ticks mod 50) * 2
  interp"${mins:02}:${secs:02}:${cents:02}"

type
  Collision {.pure.} = enum x, y, corner
  CameraMode {.pure.} = enum strict, bounds, fluid

  Time = ref object
    begin, finish, best: int

  Player = ref object
    texture: TexturePtr
    pos: Point2d
    vel: Vector2d
    time: Time

  Map = ref object
    texture: TexturePtr
    width, height: int
    tiles: seq[uint8]

  Input {.pure.} = enum none, left, right, jump, restart, quit, camera

  Camera = ref object
    mode: CameraMode
    pos: Vector2d

  Game = ref object
    inputs: array[Input, bool]
    inputPressed: array[Input, bool]
    renderer: RendererPtr
    player: Player
    camera: Camera
    map: Map
    font: FontPtr

var
  startTime = epochTime()
  lastTick = 0


proc renderText(renderer: RendererPtr, font: FontPtr, text: string, x, y, outline: cint, color: Color) =
  font.setFontOutline(outline)
  let surface = font.renderUtf8Blended(text.cstring, color)
  sdlFailIf(surface.isNil):
    "Failed to render text surface: " & text
  discard surface.setSurfaceAlphaMod(color.a)

  var
    source = rect(0, 0, surface.w, surface.h)
    dest = rect(x, y, surface.w, surface.h)
  let texture = renderer.createTextureFromSurface(surface)

  sdlFailIf(texture.isNil):
    "Failed to create texture from rendered text: " & text

  surface.freeSurface()
  renderer.copyEx(texture, source, dest, angle = 0.0, center = nil, flip = SDL_FLIP_NONE)
  texture.destroy()

proc renderText(game: Game, text: string, x, y: cint, color: Color) =
  const OUTLINE_COLOR = color(0, 0, 0, 64)
  game.renderer.renderText(game.font, text, x, y, 2, OUTLINE_COLOR)
  game.renderer.renderText(game.font, text, x, y, 0, color)


proc newCamera(): Camera =
  new result
  result.mode = CameraMode.strict
  result.pos = vector2d(0, 0)

proc restartPlayer(player: Player) =
  player.pos = point2d(170, 500)
  player.vel = vector2d(0, 0)
  player.time.begin = -1
  player.time.finish = -1

proc newTime(): Time =
  new result
  result.finish = -1
  result.best = -1

proc newPlayer(texture: TexturePtr): Player =
  new result
  result.texture = texture
  result.time = newTime()
  result.restartPlayer()

proc newMap(texture: TexturePtr, file: string): Map =
  new result
  result.texture = texture
  result.tiles = @[]

  for line in file.lines:
    var width = 0
    for word in line.split(' '):
      if word == "": continue
      let value = parseUInt(word)
      if value > uint(uint8.high):
        raise ValueError.newException("Invalid value " & word & " in map " & file)
      result.tiles.add value.uint8
      inc width
    if result.width > 0 and result.width != width:
      raise ValueError.newException("Incompatible line length in map " & file)
    result.width = width
    inc result.height

proc newGame(renderer: RendererPtr): Game =
  new result
  result.renderer = renderer
  result.player = newPlayer(renderer.loadTexture("player.png"))
  result.map = newMap(renderer.loadTexture("grass.png"), "default.map")
  result.camera = newCamera()
  result.font = openFont("DejaVuSans.ttf", 24)
  sdlFailIf(result.font.isNil):
    "Failed to load font"

const
  TILES_PER_ROW = 16
  TILE_SIZE: Point = (64.cint, 64.cint)
  PLAYER_SIZE = vector2d(64, 64)
  AIR = 0
  START = 78
  FINISH = 110
  WINDOW_SIZE: Point = (1280.cint, 720.cint)

proc wasPressed(game:Game, input:Input): bool =
  if game.inputs[input]:
    game.inputPressed[input] = true
    result = false
  else:
    if game.inputPressed[input]:
      game.inputPressed[input] = false
      result = true

proc moveCamera(game: Game) =
  if game.wasPressed(Input.camera):
    case game.camera.mode
    of CameraMode.strict: game.camera.mode = CameraMode.bounds
    of CameraMode.bounds: game.camera.mode = CameraMode.fluid
    of CameraMode.fluid: game.camera.mode = CameraMode.strict
    else: discard

  const halfWin = float(WINDOW_SIZE.x div 2)
  case game.camera.mode
  of CameraMode.strict:
    game.camera.pos.x = game.player.pos.x - halfWin
  of CameraMode.bounds:
    let
      leftBound = game.player.pos.x - halfWin - 100
      rightBound = game.player.pos.x - halfWin + 100
    game.camera.pos.x = clamp(game.camera.pos.x, leftBound, rightBound)
  of CameraMode.fluid:
    let distance = game.camera.pos.x - game.player.pos.x + halfWin
    game.camera.pos.x -= 0.05 * distance
  else: discard

proc getTile(map: Map, x, y: int): uint8 =
  let
    nx = clamp(x div TILE_SIZE.x, 0, map.width - 1)
    ny = clamp(y div TILE_SIZE.y, 0, map.height - 1)
    pos = ny * map.width + nx
  map.tiles[pos]

proc getTile(map: Map, pos: Point2d): uint8 =
  map.getTile(pos.x.round.int, pos.y.round.int)

proc isSolid(map: Map, x, y: int): bool =
  map.getTile(x, y) notin {AIR, START, FINISH}

proc isSolid(map: Map, point: Point2d): bool =
  map.isSolid(point.x.round.int, point.y.round.int)

proc onGround(map: Map, pos: Point2d, size: Vector2d): bool =
  let size = size * 0.5
  result =
    map.isSolid(point2d(pos.x - size.x, pos.y + size.y + 1)) or
    map.isSolid(point2d(pos.x + size.x, pos.y + size.y + 1))

proc testBox(map: Map, pos: Point2d, size: Vector2d): bool =
  let size = size * 0.5
  result =
    map.isSolid(point2d(pos.x - size.x, pos.y - size.y)) or
    map.isSolid(point2d(pos.x + size.x, pos.y - size.y)) or
    map.isSolid(point2d(pos.x - size.x, pos.y + size.y)) or
    map.isSolid(point2d(pos.x + size.x, pos.y + size.y))

proc moveBox(map: Map, pos: var Point2d, vel: var Vector2d, size: Vector2d): set[Collision] {.discardable.} =
  let distance = vel.len
  let maximum = distance.int
  if distance < 0:
    return

  let fraction = 1.0 / float(maximum + 1)

  for i in 0..maximum:
    var newPos = pos + vel * fraction
    if map.testBox(newPos, size):
      var hit = false
      if map.testBox(point2d(pos.x, newPos.y), size):
        result.incl Collision.y
        newPos.y = pos.y
        vel.y = 0
        hit = true
      if map.testBox(point2d(newPos.x, pos.y), size):
        result.incl Collision.x
        newPos.x = pos.x
        vel.x = 0
        hit = true
      if not hit:
        result.incl Collision.corner
        newPos = pos
        vel = vector2d(0, 0)
    pos = newPos

proc physics(game: Game) =
  if game.inputs[Input.restart]:
    game.player.restartPlayer()

  let ground = game.map.onGround(game.player.pos, PLAYER_SIZE)
  var jumping = game.player.vel.y < 0

  if game.inputs[Input.jump]:
    if ground:
      game.player.vel.y = -21
  else:
    if jumping:
      game.player.vel.y += 0.75
      game.player.vel.y += 0.75

  let direction = float(game.inputs[Input.right].int - game.inputs[Input.left].int)

  # gravity
  game.player.vel.y += 0.75
  if ground:
    game.player.vel.x = clamp(0.5 * game.player.vel.x + 4.0 * direction, -8, 8)
  else:
    game.player.vel.x = clamp(0.95 * game.player.vel.x + 2.0 * direction, -8, 8)

  game.map.moveBox(game.player.pos, game.player.vel, PLAYER_SIZE)

proc logic(game: Game, tick: int) =
  template time: untyped = game.player.time
  case game.map.getTile(game.player.pos)
  of START: time.begin = tick
  of FINISH:
    if time.begin >= 0:
      time.finish = tick - time.begin
      time.begin = -1
      if time.best < 0 or time.finish < time.best:
        time.best = time.finish
  else: discard

proc renderMap(renderer: RendererPtr, map: Map, camera: Vector2d) =
  var
    clip = rect(0, 0, TILE_SIZE.x, TILE_SIZE.y)
    dest = rect(0, 0, TILE_SIZE.x, TILE_SIZE.y)

  for i, tileId in map.tiles:
    if tileId == 0: continue

    clip.x = cint(tileId mod TILES_PER_ROW) * TILE_SIZE.x
    clip.y = cint(tileId div TILES_PER_ROW) * TILE_SIZE.y
    dest.x = cint(i mod map.width) * TILE_SIZE.x - camera.x.cint
    dest.y = cint(i div map.width) * TILE_SIZE.y - camera.y.cint

    renderer.copy(map.texture, unsafeAddr clip, unsafeAddr dest)

proc renderTee(renderer: RendererPtr, texture: TexturePtr, pos: Point2d) =
  let
    x = pos.x.cint
    y = pos.y.cint

  var bodyParts: array[8, tuple[source, dest: Rect, flip: cint]] = [
    (rect(192, 64, 64, 32), rect(x - 60, y, 96, 48), SDL_FLIP_NONE), # back feet shadow
    (rect(96, 0, 96, 96), rect(x - 48, y - 48, 96, 96), SDL_FLIP_NONE), # body shadow
    (rect(192, 64, 64, 32), rect(x - 36, y, 96, 48), SDL_FLIP_NONE), # front feet shadow
    (rect(192, 32, 64, 32), rect(x - 60, y, 96, 48), SDL_FLIP_NONE), # back feet
    (rect(0, 0, 96, 96), rect(x - 48, y - 48, 96, 96), SDL_FLIP_NONE), # body
    (rect(192, 32, 64, 32), rect(x - 36, y, 96, 48), SDL_FLIP_NONE), # front feet
    (rect(64, 96, 32, 32), rect(x - 18, y - 21, 36, 36), SDL_FLIP_NONE), # left eye
    (rect(64, 96, 32, 32), rect(x - 6, y - 21, 36, 36), SDL_FLIP_HORIZONTAL) # right eye
  ]

  for part in bodyParts.mitems:
    renderer.copyEx(texture, part.source, part.dest, angle = 0.0, center = nil, flip = part.flip)

proc toInput(key: Scancode): Input =
  case key
  of SDL_SCANCODE_A: Input.left
  of SDL_SCANCODE_D: Input.right
  of SDL_SCANCODE_LEFT: Input.left
  of SDL_SCANCODE_RIGHT: Input.right
  of SDL_SCANCODE_SPACE: Input.jump
  of SDL_SCANCODE_UP: Input.jump
  of SDL_SCANCODE_R: Input.restart
  of SDL_SCANCODE_Q: Input.quit
  of SDL_SCANCODE_ESCAPE: Input.quit
  of SDL_SCANCODE_C: Input.camera
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
  game.renderer.renderTee(game.player.texture, game.player.pos - game.camera.pos)
  game.renderer.renderMap(game.map, game.camera.pos)

  let time = game.player.time
  const WHITE = color(0xFF, 0xFF, 0xFF, 0xFF)
  if time.begin >= 0:
    game.renderText(formatTime(tick - time.begin), 50, 100, WHITE)
  elif time.finish >= 0:
    game.renderText("Finished in: " & formatTime(time.finish), 50, 100, WHITE)
  if time.best >= 0:
    game.renderText("Best time: " & formatTime(time.best), 50, 150, WHITE)
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


  var game = newGame(renderer)

  while not game.inputs[Input.quit]:
    game.handleInput()
    let newTick = int((epochTime() - startTime) * 50)
    for tick in lastTick+1..newTick:
      game.physics()
      game.moveCamera()
      game.logic(tick)
    lastTick = newTick
    game.render(lastTick)


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

when isMainModule:
  main()
