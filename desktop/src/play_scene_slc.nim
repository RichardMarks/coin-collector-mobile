import sdl2
import game_types
import scene_management

from text_renderer import renderTextCached
from game_input import wasClicked

proc registerPlayScene(scene: Scene, game: Game, tick:int) =
  # load assets here
  echo "registering play scene"

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
  discard

proc exitPlayScene(scene: Scene, game: Game, tick:int) =
  # exit animation / leave play scene here
  echo "exiting play scene"

proc destroyPlayScene(scene: Scene, game: Game, tick:int) =
  # release assets here, like at game end
  echo "destroy play scene"

let playSlc* = [
  registerPlayScene.SceneLifeCycleProc,
  enterPlayScene.SceneLifeCycleProc,
  updatePlayScene.SceneLifeCycleProc,
  renderPlayScene.SceneLifeCycleProc,
  exitPlayScene.SceneLifeCycleProc,
  destroyPlayScene.SceneLifeCycleProc]
