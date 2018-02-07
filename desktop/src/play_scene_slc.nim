import sdl2
import sdl2.image
import game_types
import scene_management

from text_renderer import renderTextCached
from game_input import wasClicked
from game_state import getBoardCell, clickBoardCell, resetBoardState

const BOARD_X*: cint = cint((SCREEN_W - BOARD_WIDTH) div 2)
const BOARD_Y*: cint = cint((SCREEN_H - BOARD_HEIGHT) div 2)

var tilesTexture: TexturePtr

proc getTileClip(cell:char): Rect =
  case cell
  of 'S': result = rect(0, 0, 64, 64)
  of 'D': result = rect(64, 0, 64, 64)
  of 'P': result = rect(0, 64, 64, 64)
  of 'C': result = rect(64, 64, 64, 64)
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
    game.sceneManager.enter("title")

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
