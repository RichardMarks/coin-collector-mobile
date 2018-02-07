import game_types
import scene_management

proc registerStartScene(scene: Scene, game: Game, tick:int) =
  # load assets here
  echo "registering start scene"

proc enterStartScene(scene: Scene, game: Game, tick:int) =
  # enter animation / show start scene here
  echo "entering start scene"

proc updateStartScene(scene: Scene, game: Game, tick:int) =
  # called on game update proc
  discard

proc renderStartScene(scene: Scene, game: Game, tick:int) =
  # called on game render proc
  discard

proc exitStartScene(scene: Scene, game: Game, tick:int) =
  # exit animation / leave start scene here
  echo "exiting start scene"

proc destroyStartScene(scene: Scene, game: Game, tick:int) =
  # release assets here, like at game end
  echo "destroy start scene"

let startSlc* = [
  registerStartScene.SceneLifeCycleProc,
  enterStartScene.SceneLifeCycleProc,
  updateStartScene.SceneLifeCycleProc,
  renderStartScene.SceneLifeCycleProc,
  exitStartScene.SceneLifeCycleProc,
  destroyStartScene.SceneLifeCycleProc]
