import sdl2.ttf
import game_types
import scene_management
from game_input import wasClicked
import text_renderer
import scoring

type
  HighScoreTableView = seq[TextObject]
  BackButton = enum
    none,
    back,

const 
  CENTER_Y = SCREEN_H div 2
  # only 10 + 1 high scores
  BOTTOM_SPACING = CENTER_Y div 8

let CENTER_X: cint = SCREEN_W div 2

var 
  scoreFont: FontPtr
  titleFont: FontPtr
  highScoreTable: HighScoreTable
  highScoreTableView: HighScoreTableView
  highScoreTitleText: TextObject
  backButtonText: TextObject
  activeButton: BackButton = BackButton.none


proc renderButton(textObj: TextObject, matchActive: BackButton) =
  if matchActive == activeButton:
    textObj.setColor(YELLOW)
  else:
    textObj.setColor(WHITE)
  textObj.render()

# called on enter and on register to update the high scores table
proc updateHighScoreListing(game: Game, highScoreTable: HighScoreTable): HighScoreTableView =

  var highScoreTableView: HighScoreTableView = newSeq[TextObject]()

  for score in highScoreTable.data:
    let highScoreText: TextObject = newTextObject(game.renderer, scoreFont, WHITE)
    highScoreText.setText($score.initials[0] & $score.initials[1] & $score.initials[2] & " - " & $score.score)
    highScoreTableView.add(highScoreText)

  for index, text in highScoreTableView:
    text.setPivot(0.5, 0.5)
    text.x = CENTER_X
    text.y = cint(CENTER_Y + BOTTOM_SPACING * index - 165)
  result = highScoreTableView

proc registerViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # load assets here
  scoreFont = openFont("../kaiju.ttf", 40)
  sdlFailIf(scoreFont.isNil): "Failed to load kaiju.ttf"

  titleFont = openFont("../kaiju.ttf", 56)
  sdlFailIf(scoreFont.isNil): "Failed to load kaiju.ttf"

  highScoreTable = loadHighScores()
  highScoreTableView = updateHighScoreListing(game, highScoreTable)

  highScoreTitleText = newTextObject(game.renderer, titleFont, WHITE)

  highScoreTitleText.setText("High Scores")
  highScoreTitleText.setPivot(0.5, 0.5)
  highScoreTitleText.x = CENTER_X
  highScoreTitleText.y = cint(SCREEN_H * 0.1)

  backButtonText = newTextObject(game.renderer, game.menuItemFont, WHITE)
  backButtonText.setText("back")
  backButtonText.setPivot(0.5, 0.5)
  backButtonText.x = cint(CENTER_X div 2)
  backButtonText.y = CENTER_Y

proc enterViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # enter animation / show Viewhighscores scene here
  highScoreTable = loadHighScores()
  highScoreTableView = updateHighScoreListing(game, highScoreTable)

proc updateViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # called on game update proc
  
  let mx: cint = game.mouse.x.cint
  let my: cint = game.mouse.y.cint
  
  if backButtonText.containsPoint(mx, my): activeButton = BackButton.back
  else: activeButton = BackButton.none

  if game.wasClicked():
    if backButtonText.containsPoint(mx, my):
      game.sceneManager.enter("title")


proc renderViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # called on game render proc
  highScoreTitleText.render()
  backButtonText.renderButton(BackButton.back)

  for index, text in highScoreTableView:
    text.render()

proc exitViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # exit animation / leave Viewhighscores scene here
  discard

proc destroyViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # release assets here, like at game end
  scoreFont.close()
  titleFont.close()

let viewhighscoresSlc* = [
  registerViewhighscoresScene.SceneLifeCycleProc,
  enterViewhighscoresScene.SceneLifeCycleProc,
  updateViewhighscoresScene.SceneLifeCycleProc,
  renderViewhighscoresScene.SceneLifeCycleProc,
  exitViewhighscoresScene.SceneLifeCycleProc,
  destroyViewhighscoresScene.SceneLifeCycleProc]
