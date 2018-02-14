import game_types
import scene_management
from game_input import wasClicked
import text_renderer
import scoring

type
  HighScoreTableView = seq[TextObject]

const CENTER_Y = SCREEN_H div 2
# only 10 + 1 high scores
const BOTTOM_SPACING = CENTER_Y div 11
let centerX: cint = SCREEN_W div 2

var 
  highScoreTable: HighScoreTable
  highScoreTableView: HighScoreTableView


proc updateHighScoreListing(game: Game, highScoreTable: HighScoreTable): HighScoreTableView =
  var highScoreTableView: HighScoreTableView = newSeq[TextObject]()
  for score in highScoreTable.data:
    var highScoreText: TextObject = newTextObject(game.renderer, game.menuItemFont, WHITE)
    highScoreText.setText($score.initials[0] & $score.initials[1] & $score.initials[2] & " - " & $score.score)
    highScoreTableView.add(highScoreText)
  # echo repr(highScoreTableView)
  result = highScoreTableView

proc registerViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # load assets here

  highScoreTable = loadHighScores()
  # echo repr(highScoreTable)
  highScoreTableView = updateHighScoreListing(game, highScoreTable)
  for index, text in highScoreTableView:
    text.setPivot(0.5, 0.5)
    text.x = centerX
    text.y = cint(CENTER_Y + BOTTOM_SPACING * index * 2 - 275)
  discard

proc enterViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # enter animation / show Viewhighscores scene here
  highScoreTable = loadHighScores()
  highScoreTableView = updateHighScoreListing(game, highScoreTable)
  for index, text in highScoreTableView:
    text.setPivot(0.5, 0.5)
    text.x = centerX
    text.y = cint(CENTER_Y + BOTTOM_SPACING * index * 2 - 275)
  discard

proc updateViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # called on game update proc
  if game.wasClicked():
    game.sceneManager.enter("title")
  discard

proc renderViewhighscoresScene(scene: Scene, game: Game, tick: float) =
  # called on game render proc
  # TODO: replace this old "renderTextCached" procedure call
  game.renderTextCached("View High Scores Scene", 500, 20, WHITE )
  for index, text in highScoreTableView:
    text.render()

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
