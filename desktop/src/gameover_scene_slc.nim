import game_types
import scene_management
from game_input import wasClicked
from text_renderer import renderTextCached

proc registerGameoverScene(scene: Scene, game: Game, tick: float) =
  # load assets here
  discard

proc enterGameoverScene(scene: Scene, game: Game, tick: float) =
  # enter animation / show gameover scene here
  discard

proc updateGameoverScene(scene: Scene, game: Game, tick: float) =
  # called on game update proc
  if game.wasClicked():
    game.sceneManager.enter("title")

proc renderGameoverScene(scene: Scene, game: Game, tick: float) =
  # called on game render proc
  let
    coins: string = $game.state.coins

  if game.state.timer == 0:
    game.renderTextCached("TIME'S UP!", 560, 340, WHITE )
  else:
    game.renderTextCached("G A M E  O V E R", 560, 340, WHITE )
  game.renderTextCached("SCORE: " & coins, 567, 375, WHITE )

proc exitGameoverScene(scene: Scene, game: Game, tick: float) =
  # exit animation / leave gameover scene here
  discard

proc destroyGameoverScene(scene: Scene, game: Game, tick: float) =
  # release assets here, like at game end
  discard

let gameoverSlc* = [
  registerGameoverScene.SceneLifeCycleProc,
  enterGameoverScene.SceneLifeCycleProc,
  updateGameoverScene.SceneLifeCycleProc,
  renderGameoverScene.SceneLifeCycleProc,
  exitGameoverScene.SceneLifeCycleProc,
  destroyGameoverScene.SceneLifeCycleProc]
