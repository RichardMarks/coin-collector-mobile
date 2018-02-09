import sdl2
import game_types
import scene_management

from text_renderer import renderTextCached
from game_input import wasClicked

proc drawCreditSceneText(game: Game) =

  game.renderTextCached("Thanks for playing!", 510, 260, WHITE)
  game.renderTextCached("Created by:", 550, 340, WHITE)
  game.renderTextCached("Richard Marks", 535, 400, WHITE)
  game.renderTextCached("Stephen Collins", 530, 435, WHITE)
  game.renderTextCached("Click to go back", 525, 570, WHITE)


proc registerCreditsScene(scene: Scene, game: Game, tick:int) =
  # load assets here
  echo "registering credits scene"

proc enterCreditsScene(scene: Scene, game: Game, tick:int) =
  # enter animation / show credits scene here
  echo "entering credits scene"

  game.renderer.setDrawColor(r = 0x90, g = 0x30, b = 0x50)

proc updateCreditsScene(scene: Scene, game: Game, tick:int) =
  # called on game update proc
  if game.wasClicked():
    game.sceneManager.enter("title")

proc renderCreditsScene(scene: Scene, game: Game, tick:int) =
  # called on game render proc
  game.drawCreditSceneText()

proc exitCreditsScene(scene: Scene, game: Game, tick:int) =
  # exit animation / leave credits scene here
  echo "exiting credits scene"

proc destroyCreditsScene(scene: Scene, game: Game, tick:int) =
  # release assets here, like at game end
  echo "destroy credits scene"

let creditsSlc* = [
  registerCreditsScene.SceneLifeCycleProc,
  enterCreditsScene.SceneLifeCycleProc,
  updateCreditsScene.SceneLifeCycleProc,
  renderCreditsScene.SceneLifeCycleProc,
  exitCreditsScene.SceneLifeCycleProc,
  destroyCreditsScene.SceneLifeCycleProc]
