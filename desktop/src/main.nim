# import basic2d
# import strutils
# import math
# import strfmt
# import streams
# import os

import times
import sdl2
import sdl2.image
import sdl2.ttf

import game_types
import scene_management
from game_input import handleInput
from game_state import getInitialState
from scenes import titleScene, creditsScene, gameoverScene, playScene

from text_renderer import renderTextCached

proc newGame(renderer: RendererPtr): Game =
  new result
  result.getInitialState()
  result.sceneManager = newGameSceneManager(result)
  result.renderer = renderer

  result.font = openFont("../DejaVuSans.ttf", 24)
  sdlFailIf(result.font.isNil): "Failed to load DejaVuSans.ttf"

  result.menuItemFont = openFont("../kaiju.ttf", 48)
  sdlFailIf(result.menuItemFont.isNil): "Failed to load kaiju.ttf"

  # register all game scenes
  for scene in [
    titleScene,
    creditsScene,
    gameoverScene,
    playScene
  ]:
    result.sceneManager.register(scene)

  # load the initial scene
  result.sceneManager.enter("title")

proc update(game: Game, tick: float) =
  let scene = game.sceneManager.current
  if scene != nil:
    scene.onUpdate(scene, game, tick)
  else:
    game.inputs[Input.quit] = true

proc render(game: Game, tick: float) =
  const WHITE = color(0xFF, 0xFF, 0xFF, 0xFF)

  game.renderer.clear()
  let scene = game.sceneManager.current
  if scene != nil:
    scene.onRender(scene, game, tick)
    # game.renderTextCached("[" & scene.name & "]", 0, 0, WHITE)
  else:
    game.renderTextCached("[NO SCENE]", 0, 0, WHITE)
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
    flags = SDL_WINDOW_SHOWN or SDL_WINDOW_RESIZABLE)
  sdlFailIf(window.isNil):
    "Failed to create window"
  defer:
    window.destroy()

  let renderer = window.createRenderer(
    index = -1,
    flags = sdl2.Renderer_Accelerated or sdl2.Renderer_PresentVsync or sdl2.Renderer_TargetTexture)
  sdlFailIf(renderer.isNil):
    "Failed to create renderer"
  defer:
    renderer.destroy()

  renderer.setDrawColor(r = 0x30, g = 0x60, b = 0x90)

  var
    game = newGame(renderer)
    lastTime = epochTime()
    # startTime = epochTime()
    # lastTick = 0

  defer:
    # cleanup the scenes when the main proc exits
    for scene in [
      titleScene,
      creditsScene,
      gameoverScene,
      playScene
    ]:
      game.sceneManager.destroy(scene.name)
    game.menuItemFont.close()
    game.font.close()

  discard renderer.setLogicalSize(1280, 720)
  # window.maximizeWindow()

  while not game.inputs[Input.quit]:
    game.handleInput()
    let newTime = epochTime()
    if newTime - lastTime < 1:
      var dt = (newTime - lastTime)
      game.update(dt)
    lastTime = newTime
    # let newTick = int((epochTime() - startTime) * 50)
    # for tick in lastTick+1..newTick:
    #   game.update(tick)
    # lastTick = newTick
    game.render(lastTime)

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
