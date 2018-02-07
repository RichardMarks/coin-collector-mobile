import game_types
import scene_management

proc registerGameoverScene(scene: Scene, game: Game, tick:int) =
  # load assets here
  echo "registering gameover scene"

proc enterGameoverScene(scene: Scene, game: Game, tick:int) =
  # enter animation / show gameover scene here
  echo "entering gameover scene"

proc updateGameoverScene(scene: Scene, game: Game, tick:int) =
  # called on game update proc
  discard

proc renderGameoverScene(scene: Scene, game: Game, tick:int) =
  # called on game render proc
  discard

proc exitGameoverScene(scene: Scene, game: Game, tick:int) =
  # exit animation / leave gameover scene here
  echo "exiting gameover scene"

proc destroyGameoverScene(scene: Scene, game: Game, tick:int) =
  # release assets here, like at game end
  echo "destroy gameover scene"

let gameoverSlc* = [
  registerGameoverScene.SceneLifeCycleProc,
  enterGameoverScene.SceneLifeCycleProc,
  updateGameoverScene.SceneLifeCycleProc,
  renderGameoverScene.SceneLifeCycleProc,
  exitGameoverScene.SceneLifeCycleProc,
  destroyGameoverScene.SceneLifeCycleProc]
