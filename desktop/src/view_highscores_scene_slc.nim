import game_types
import scene_management
from game_input import wasClicked
from text_renderer import renderTextCached

proc registerViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # load assets here
  discard

proc enterViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # enter animation / show Viewhighscores scene here
  discard

proc updateViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # called on game update proc
  # if game.wasClicked():
  #   game.sceneManager.enter("title")
  discard

proc renderViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # called on game render proc
  game.renderTextCached("View High Scores Scene", 560, 340, WHITE )
  echo "show high score list: ", repr(game.state.highScoresList)


proc exitViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # exit animation / leave Viewhighscores scene here
  discard

proc destroyViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # release assets here, like at game end
  discard

let viewhighscoresSlc* = [
  registerViewhighscoresScene.SceneLifeCycleProc,
  enterViewhighscoresScene.SceneLifeCycleProc,
  updateViewhighscoresScene.SceneLifeCycleProc,
  renderViewhighscoresScene.SceneLifeCycleProc,
  exitViewhighscoresScene.SceneLifeCycleProc,
  destroyViewhighscoresScene.SceneLifeCycleProc]
