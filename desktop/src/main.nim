import sdl2

type SDLException = object of Exception

template sdlFailIf(condition: typed, reason: string) =
  if condition:
    raise SDLException.newException(reason & ", SDL Error" & $getError())

proc main() =
  sdlFailIf(not sdl2.init(INIT_EVERYTHING)):
    "Failed to initialize SDL2"

  defer:
    sdl2.quit()

  sdlFailIf(not sdl2.setHint("SDL_RENDER_SCALE_QUALITY", "2")):
    "Failed to set linear texture filtering"

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

  var masterEvent: sdl2.Event = sdl2.defaultEvent
  var isRunning: bool = true
  while isRunning:
    while sdl2.pollEvent(masterEvent):
      case masterEvent.kind:
        of sdl2.QuitEvent: isRunning = false
        of sdl2.KeyDown:
          if masterEvent.key.keysym.sym == sdl2.K_ESCAPE:
            isRunning = false
        else: discard
    renderer.clear()
    renderer.present()

when isMainModule:
  main()
