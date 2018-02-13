import sdl2, sdl2.ttf
import game_types
import scene_management

from text_renderer import TextObject, newTextObject, render, setText, setColor, setPivot, setScale, containsPoint
from game_input import wasClicked
from game_state import getInitialState

type
  TitleButton = enum
    none,
    play,
    credits,
    highscores,
    quit

var
  activeButton: TitleButton = TitleButton.none
  gameNameText: TextObject
  playText: TextObject
  creditsText: TextObject
  highScoresText: TextObject
  quitText: TextObject
  gameNameFont: FontPtr

proc registerTitleScene(scene: Scene, game: Game, tick: float) =
  # load assets here

  gameNameFont = openFont("../talacha.ttf", 120)
  sdlFailIf(gameNameFont.isNil): "Failed to load talacha.ttf"

  gameNameText = newTextObject(game.renderer, gameNameFont, WHITE)
  playText = newTextObject(game.renderer, game.menuItemFont, WHITE)
  creditsText = newTextObject(game.renderer, game.menuItemFont, WHITE)
  highScoresText = newTextObject(game.renderer, game.menuItemFont, WHITE)
  quitText = newTextObject(game.renderer, game.menuItemFont, WHITE)

  gameNameText.setText("Coin Collector")

  playText.setText("Play")
  creditsText.setText("Credits")
  highScoresText.setText("High Scores")
  quitText.setText("Quit")

  # divide the screen in 2 halves vertically
  const CENTER_Y = SCREEN_H div 2

  # divide the bottom half by 1 + number of menu items
  # to equally distribute the menu items in the space
  const BOTTOM_SPACING = CENTER_Y div 5

  # center all text on x
  # position each menu item in the correct location
  let centerX: cint = SCREEN_W div 2
  for index, txt in [
    gameNameText,
    playText,
    creditsText,
    highScoresText,
    quitText
  ]:
    txt.setPivot(0.5, 0.5)
    txt.x = centerX

    # menu items only
    if txt != gameNameText:
      txt.y = CENTER_Y + BOTTOM_SPACING * index

  gameNameText.y = 220

proc enterTitleScene(scene: Scene, game: Game, tick: float) =
  # enter animation / show title scene here

  game.getInitialState()
  game.renderer.setDrawColor(r = 0x50, g = 0x30, b = 0x90)

proc updateTitleScene(scene: Scene, game: Game, tick: float) =
  # called on game update proc

  # the mouse position is constantly tracked by handleInput in game_input.nim
  # grab a local reference to the mouse position
  let mx: cint = game.mouse.x.cint
  let my: cint = game.mouse.y.cint

  # determine which button is active using simple if mouse coordinate within rectangle logic
  if playText.containsPoint(mx, my): activeButton = TitleButton.play
  elif creditsText.containsPoint(mx, my): activeButton = TitleButton.credits
  elif highScoresText.containsPoint(mx, my): activeButton = TitleButton.highscores
  elif quitText.containsPoint(mx, my): activeButton = TitleButton.quit
  else: activeButton = TitleButton.none

  # if the mouse was clicked handle each button's click as needed
  if game.wasClicked():
    case activeButton
    of TitleButton.play:
      game.sceneManager.exit(scene.name)
      game.sceneManager.enter("play")
    of TitleButton.credits:
      game.sceneManager.exit(scene.name)
      game.sceneManager.enter("credits")
    of TitleButton.highscores:
      game.sceneManager.exit(scene.name)
      game.sceneManager.enter("viewhighscores")
    of TitleButton.quit:
      game.sceneManager.exit(scene.name)
    else: discard

proc renderButton(textObj: TextObject, matchActive: TitleButton) =
  if matchActive == activeButton:
    textObj.setColor(YELLOW)
  else:
    textObj.setColor(WHITE)
  textObj.render()

proc renderTitleScene(scene: Scene, game: Game, tick: float) =
  # called on game render proc

  gameNameText.render()
  playText.renderButton(TitleButton.play)
  creditsText.renderButton(TitleButton.credits)
  highScoresText.renderButton(TitleButton.highscores)
  quitText.renderButton(TitleButton.quit)

proc exitTitleScene(scene: Scene, game: Game, tick: float) =
  # exit animation / leave title scene here
  discard

proc destroyTitleScene(scene: Scene, game: Game, tick: float) =
  # release assets here, like at game end
  gameNameFont.close()

let titleSlc* = [
  registerTitleScene.SceneLifeCycleProc,
  enterTitleScene.SceneLifeCycleProc,
  updateTitleScene.SceneLifeCycleProc,
  renderTitleScene.SceneLifeCycleProc,
  exitTitleScene.SceneLifeCycleProc,
  destroyTitleScene.SceneLifeCycleProc]
