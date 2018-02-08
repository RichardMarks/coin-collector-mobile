import sdl2
import game_types
import scene_management

from text_renderer import renderTextCached
from game_input import wasClicked
from game_state import getInitialState

type
  TitleButton = enum
    none,
    play,
    credits,
    quit

var activeButton: TitleButton = TitleButton.none

proc registerTitleScene(scene: Scene, game: Game, tick:int) =
  # load assets here
  echo "registering title scene"

proc enterTitleScene(scene: Scene, game: Game, tick:int) =
  # enter animation / show title scene here
  echo "entering title scene"

  game.getInitialState()
  game.renderer.setDrawColor(r = 0x50, g = 0x30, b = 0x90)

proc updateTitleScene(scene: Scene, game: Game, tick:int) =
  # called on game update proc

  # the mouse position is constantly tracked by handleInput in game_input.nim
  # grab a local reference to the mouse position
  let mx = game.mouse.x
  let my = game.mouse.y

  # button hitboxes - these values were determined manually..
  # we could refactor this, but I don't think we need to

  # PLAY:    left: 571, top: 356, right: 734, bottom: 393
  # CREDITS: left: 594, top: 435, right: 712, bottom: 480
  # QUIT:    left: 611, top: 526, right: 696, bottom: 569

  # determine which button is active using simple if mouse coordinate within rectangle logic
  activeButton = TitleButton.none
  if mx >= 571 and mx <= 734 and my >= 356 and my <= 393:
    activeButton = TitleButton.play
  if mx >= 594 and mx <= 712 and my >= 435 and my <= 480:
    activeButton = TitleButton.credits
  if mx >= 611 and mx <= 696 and my >= 526 and my <= 569:
    activeButton = TitleButton.quit

  # if the mouse was clicked handle each button's click as needed
  if game.wasClicked():
    case activeButton
    of TitleButton.play:
      game.sceneManager.exit(scene.name)
      game.sceneManager.enter("play")
    of TitleButton.credits:
      game.sceneManager.exit(scene.name)
      game.sceneManager.enter("credits")
    of TitleButton.quit:
      game.sceneManager.exit(scene.name)
    else: discard

proc renderButton(game: Game, label: string, x, y: int, isActive: bool) =
  ## renders a button (white text label by default, yellow text label for hover)
  var textColor = WHITE
  if isActive:
    textColor = YELLOW
  game.renderTextCached(label, x.cint, y.cint, textColor)

proc renderTitleScene(scene: Scene, game: Game, tick:int) =
  # called on game render proc

  game.renderTextCached("Coin Collector", 560, 220, WHITE)
  game.renderButton("Play Game", 585, 358, activeButton == TitleButton.play)
  game.renderButton("Credits", 608, 442, activeButton == TitleButton.credits)
  game.renderButton("Quit", 625, 530, activeButton == TitleButton.quit)

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
