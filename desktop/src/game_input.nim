import sdl2
import game_types

proc wasPressed*(game: Game, input: Input): bool =
  if game.inputs[input]:
    game.inputPressed[input] = true
    result = false
  else:
    if game.inputPressed[input]:
      game.inputPressed[input] = false
      result = true

proc wasClicked*(game: Game): bool =
  result = wasPressed(game, Input.mouse)

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

proc handleInput*(game: Game) =
  var event = defaultEvent
  while pollEvent(event):
    case event.kind
    of QuitEvent: game.inputs[Input.quit] = true
    of KeyDown: game.inputs[event.key.keysym.scancode.toInput] = true
    of KeyUp: game.inputs[event.key.keysym.scancode.toInput] = false
    of MouseButtonDown: game.inputs[Input.mouse] = true
    of MouseButtonUp: game.inputs[Input.mouse] = false
    of MouseMotion:
      game.mouse.x = event.motion.x
      game.mouse.y = event.motion.y
    else: discard
