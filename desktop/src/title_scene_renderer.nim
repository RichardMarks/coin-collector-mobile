import game_types
import scene_management
# title screen:
#                    Coin Collector
#
#          by Richard Marks and Stephen Collins
#
#                      Play Game
#                      Settings
#                        Quit
#
#
#

proc registerTitleScene(scene: Scene, game: Game, tick:int) =
  # load assets here
  echo "registering title scene"

proc enterTitleScene(scene: Scene, game: Game, tick:int) =
  # enter animation / show title scene here
  echo "entering title scene"

proc updateTitleScene(scene: Scene, game: Game, tick:int) =
  # called on game update proc
  echo "registering title scene"

proc renderTitleScene(scene: Scene, game: Game, tick:int) =
  # called on game render proc
  echo "rendering title scene"

proc exitTitleScene(scene: Scene, game: Game, tick:int) =
  # exit animation / leave title scene here
  echo "exiting title scene"

proc destroyTitleScene(scene: Scene, game: Game, tick:int) =
  # release assets here, like at game end
  echo "destroy title scene"

let titleSlc* = [
  registerTitleScene.SceneLifeCycleProc,
  enterTitleScene.SceneLifeCycleProc,
  updateTitleScene.SceneLifeCycleProc,
  renderTitleScene.SceneLifeCycleProc,
  exitTitleScene.SceneLifeCycleProc,
  destroyTitleScene.SceneLifeCycleProc]
