import game_types
import scene_management
from game_input import wasClicked
from text_renderer import renderTextCached
import scoring

proc registerHighscoreScene(scene: Scene, game: Game, tick: float) =
  # load assets here
  discard

proc enterHighscoreScene(scene: Scene, game: Game, tick: float) =
  # enter animation / show Highscore scene here
  discard

proc updateHighscoreScene(scene: Scene, game: Game, tick: float) =
  # called on game update proc
  # if game.wasClicked():
  #   game.sceneManager.enter("title")
  discard

proc renderHighscoreScene(scene: Scene, game: Game, tick: float) =
  # called on game render proc
  game.renderTextCached("High Score Scene", 560, 340, WHITE )


proc exitHighscoreScene(scene: Scene, game: Game, tick: float) =
  # exit animation / leave Highscore scene here
  discard

proc destroyHighscoreScene(scene: Scene, game: Game, tick: float) =
  # release assets here, like at game end
  discard

let highscoreSlc* = [
  registerHighscoreScene.SceneLifeCycleProc,
  enterHighscoreScene.SceneLifeCycleProc,
  updateHighscoreScene.SceneLifeCycleProc,
  renderHighscoreScene.SceneLifeCycleProc,
  exitHighscoreScene.SceneLifeCycleProc,
  destroyHighscoreScene.SceneLifeCycleProc]
