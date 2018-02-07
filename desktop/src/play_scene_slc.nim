import sdl2
import sdl2.image
import game_types
import scene_management

from text_renderer import renderTextCached
from game_input import wasClicked
from game_state import getBoardCell, clickBoardCell, resetBoardState, STONE_TILE, DIRT_TILE, PIT_TILE, COIN_TILE

const BOARD_X*: cint = cint((SCREEN_W - BOARD_WIDTH) div 2)
const BOARD_Y*: cint = cint((SCREEN_H - BOARD_HEIGHT) div 2)

var tilesTexture: TexturePtr

let regionRects: array[2, Rect] = [
  rect(BOARD_X, BOARD_Y, BOARD_WIDTH.cint, BOARD_HEIGHT.cint),
  rect(0, 0, 120, 40)
]

proc onClick(game: Game) =
  let mx = game.mouse.x
  let my = game.mouse.y

  if regionRects[0].contains(point(mx, my)):
    # clicked on board
    let x: int = (mx - BOARD_X) div TILE_WIDTH
    let y: int = (my - BOARD_Y) div Y_SPACE
    # echo "clicking tile @[" & $x & ", " & $y & "]"
    let boardEvent = game.clickBoardCell(x, y)
    case boardEvent
    of BoardEvent.foundDirt: echo "found dirt!"
    of BoardEvent.foundPit: echo "found a pit and lost a life!"
    of BoardEvent.foundCoin: echo "found a coin"
    of BoardEvent.takeCoin: echo "picked up a coin!"
    if game.state.lives == 0:
      echo "lost all lives. game over man"
      game.sceneManager.enter("gameover")
    elif game.state.board.contains('S') == false:
      echo "all tiles flipped, need to reset the board"
      game.resetBoardState()
  elif regionRects[1].contains(point(mx, my)):
    # clicked on quit button
    game.sceneManager.enter("title")

proc getTileClip(cell:char): Rect =
  case cell
  of STONE_TILE: result = rect(0, 0, 64, 64)
  of DIRT_TILE: result = rect(64, 0, 64, 64)
  of PIT_TILE: result = rect(0, 64, 64, 64)
  of COIN_TILE: result = rect(64, 64, 64, 64)
  else: discard

proc registerPlayScene(scene: Scene, game: Game, tick:int) =
  # load assets here
  echo "registering play scene"
  echo "loading tiles.png"
  tilesTexture = game.renderer.loadTexture("../tiles.png")

proc enterPlayScene(scene: Scene, game: Game, tick:int) =
  # enter animation / show play scene here
  echo "entering play scene"

  game.renderer.setDrawColor(r = 0x30, g = 0x50, b = 0x90)

proc updatePlayScene(scene: Scene, game: Game, tick:int) =
  # called on game update proc
  if game.wasClicked():
    game.onClick()

proc renderPlayScene(scene: Scene, game: Game, tick:int) =
  # called on game render proc

  for y in 0..BOARD_YLIMIT:
    for x in 0..BOARD_XLIMIT:
      let cell = game.getBoardCell(x, y)
      var clip = cell.getTileClip()
      var dest = rect(BOARD_X + cint(x * TILE_WIDTH), BOARD_Y + cint(y * Y_SPACE), TILE_WIDTH, TILE_HEIGHT)
      game.renderer.copy(tilesTexture, unsafeAddr clip, unsafeAddr dest)

proc exitPlayScene(scene: Scene, game: Game, tick:int) =
  # exit animation / leave play scene here
  echo "exiting play scene"

proc destroyPlayScene(scene: Scene, game: Game, tick:int) =
  # release assets here, like at game end
  echo "destroy play scene"
  destroyTexture(tilesTexture)

let playSlc* = [
  registerPlayScene.SceneLifeCycleProc,
  enterPlayScene.SceneLifeCycleProc,
  updatePlayScene.SceneLifeCycleProc,
  renderPlayScene.SceneLifeCycleProc,
  exitPlayScene.SceneLifeCycleProc,
  destroyPlayScene.SceneLifeCycleProc]
