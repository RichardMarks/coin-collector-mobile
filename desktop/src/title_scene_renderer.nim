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

proc registerTitleScene() =
  # load assets here
  echo "registering title scene"
echo "from export:", repr(registerTitleScene)
proc enterTitleScene() =
  # enter animation / show title scene here
  echo "registering title scene"

proc updateTitleScene() =
  # called on game update proc
  echo "registering title scene"

proc renderTitleScene() =
  # called on game render proc  
  echo "registering title scene"

proc exitTitleScene() =
  # exit animation / leave title scene here  
  echo "registering title scene"

proc destroyTitleScene() =
  # release assets here, like at game end
  echo "registering title scene"

let titleSlc* = [
  registerTitleScene.SceneLifeCycleProc,
  enterTitleScene.SceneLifeCycleProc,
  updateTitleScene.SceneLifeCycleProc,
  renderTitleScene.SceneLifeCycleProc,
  exitTitleScene.SceneLifeCycleProc,
  destroyTitleScene.SceneLifeCycleProc
  ]


# let titleScene = newScene(
#   "title",
#   newSeq[SceneObject](0),
#   [registerTitleScene.SceneLifeCycleProc,
#   enterTitleScene.SceneLifeCycleProc,
#   updateTitleScene.SceneLifeCycleProc,
#   renderTitleScene.SceneLifeCycleProc,
#   exitTitleScene.SceneLifeCycleProc,
#   destroyTitleScene.SceneLifeCycleProc]
# )