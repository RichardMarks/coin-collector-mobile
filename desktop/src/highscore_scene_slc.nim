import sdl2, sdl2.image, sdl2.ttf
import nre
import game_types
import scene_management
from game_input import wasClicked
import text_renderer
import scoring

type
  UnderscorePos = enum left, middle, right, selected
  ArrowType = enum leftArrow, rightArrow

  ArrowObject = ref object
    texture: TexturePtr

    # 0 = left, 1 = right
    arrowType: ArrowType
    renderer: RendererPtr
    # just the upper left corner of rough arrow area
    src: Rect
    dst: Rect

  UnderScoreObject = ref object
    texture: TexturePtr
    renderer: RendererPtr
    src: Rect
    dst: Rect

const 
  CENTER_X = SCREEN_W div 2
  CENTER_Y = SCREEN_H div 2

  LEFT_UNDERSCORE_X: cint = cint(CENTER_X * 0.8 - 55)
  TOP_UNDERSCORES_Y: cint = cint(CENTER_Y)
  SELECTED_UNDERSCORE_Y: cint = cint(CENTER_Y * 1.5)

  MIDDLE_UNDERSCORE_X: cint = cint(CENTER_X - 55)

  RIGHT_UNDERSCORE_X: cint = cint(CENTER_X * 1.2 - 55)

var
  arrowsTexture: TexturePtr
  underscoreTexture: TexturePtr

  # arrow objects
  leftArrowObj: ArrowObject
  rightArrowObj: ArrowObject

  # underscore objects
  leftUnderscoreObj: UnderScoreObject
  middleUnderscoreObj: UnderScoreObject
  rightUnderscoreObj: UnderScoreObject
  selectedUnderscoreObj: UnderScoreObject

  smallTextFont: FontPtr
  mediumTextFont: FontPtr
  selectedTextFont: FontPtr


  currIndex: int = 2

  # scene text objects
  titleTextObj: TextObject
  scoreTextObj: TextObject
  selectedTextObj: TextObject
  firstEntererdTextObj: TextObject
  secondEntererdTextObj: TextObject
  thirdEntererdTextObj: TextObject
  mediumLeftTextObj: TextObject
  mediumRightTextObj: TextObject
  smallLeftTextObj: TextObject
  smallRightTextObj: TextObject

let 
  alphabet: seq[string] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".split(re"")
  playerScore: string = $(12345) #$(game.state.coins * 1000)

proc newArrowObject(renderer: RendererPtr, texture: TexturePtr, arrowType: ArrowType): ArrowObject =
  new result

  result.renderer = renderer
  result.texture = texture
  case arrowType
  of leftArrow:
    result.src = rect(0,0,50,100)
    result.dst = rect(cint(LEFT_UNDERSCORE_X - 55), cint(CENTER_Y * 1.2), 50, 100)
  of rightArrow:
    result.src = rect(50,0,50,100)
    # TODO: figure out why this positioning does not *evenly* line up with the underscore objects
    result.dst = rect(cint(RIGHT_UNDERSCORE_X + 120), cint(CENTER_Y * 1.2), 50, 100)
  else:
    raise SystemError.newException("Invalid arrow type supplied")

proc newUnderscoreObject(renderer: RendererPtr, texture: TexturePtr, pos: UnderscorePos): UnderscoreObject =
  new result

  result.renderer = renderer
  result.texture = texture
  result.src = rect(0,0,100,100)

  # TODO: figure out easier way to handle underscore positioning
  case pos
  of left:
    result.dst = rect(LEFT_UNDERSCORE_X, TOP_UNDERSCORES_Y, 100, 100)
  of middle:
    result.dst = rect(MIDDLE_UNDERSCORE_X, TOP_UNDERSCORES_Y, 100, 100)
  of right:
    result.dst = rect(RIGHT_UNDERSCORE_X, TOP_UNDERSCORES_Y, 100, 100)
  of selected:
    result.dst = rect(MIDDLE_UNDERSCORE_X, SELECTED_UNDERSCORE_Y, 100, 100)
  
  else:
    raise SystemError.newException("Invalid UnderscorePos supplied")

proc renderUnderscore(game: Game, underscoreObj: UnderScoreObject) =
  game.renderer.copy(underscoreObj.texture, addr underscoreObj.src, addr underscoreObj.dst)

proc renderArrow(game: Game,arrowObj: ArrowObject ) =
  game.renderer.copy(arrowObj.texture, addr arrowObj.src, addr arrowObj.dst)

proc renderLetter(textObj: TextObject, index: int) =

  var modIndex: int = index
  # small left letter = index - 2
  # medium left letter = index - 1
  # selected letter = index
  # medium right letter = index + 1
  # small right letter = index + 2

  # if left arrow clicked then dec(index)
  # if dec(indexOfAnyLetter) < 0 then indexOfAnyLetter = alphabet.len - 1

  # if right arrow clicked then inc(index)
  # if inc(indexOfAnyLetter) > alphabet.len - 1 then indexOfAnyLetter = 0

  if (modIndex < 0):
    modIndex = alphabet.len - 1
  elif (modIndex > alphabet.len - 1):
    modIndex = 0

  textObj.setText(alphabet[modIndex])
  textObj.render()

proc registerHighscoreScene(scene: Scene, game: Game, tick: float) =
  # load assets here

  # TODO: possibly handle font size with TextObject scaling instead of large fonts
  # which could also reduce usage of FontPtrs as well
  smallTextFont = openFont("../monofonto.ttf", 50)
  sdlFailIf(smallTextFont.isNil): "Failed to load Imperator.ttf"
  
  mediumTextFont = openFont("../monofonto.ttf", 70)
  sdlFailIf(mediumTextFont.isNil): "Failed to load Imperator.ttf"
  
  selectedTextFont = openFont("../monofonto.ttf", 100)
  sdlFailIf(selectedTextFont.isNil): "Failed to load Imperator.ttf"

  arrowsTexture = game.renderer.loadTexture("../arrows.png")
  sdlFailIf(arrowsTexture.isNil): "Failed to load arrows.png"

  leftArrowObj = newArrowObject(game.renderer, arrowsTexture, ArrowType.leftArrow)
  rightArrowObj = newArrowObject(game.renderer, arrowsTexture, ArrowType.rightArrow)

  underscoreTexture = game.renderer.loadTexture("../grey-underscore.png")
  sdlFailIf(underscoreTexture.isNil): "Failed to load grey-underscore.png"

  leftUnderscoreObj = newUnderscoreObject(game.renderer,underscoreTexture,UnderscorePos.left)
  middleUnderscoreObj = newUnderscoreObject(game.renderer,underscoreTexture,UnderscorePos.middle)
  rightUnderscoreObj = newUnderscoreObject(game.renderer,underscoreTexture,UnderscorePos.right)
  selectedUnderscoreObj = newUnderscoreObject(game.renderer,underscoreTexture,UnderscorePos.selected)
  
  # instantiate scene text objects
  # entererdTextObj = newTextObject(game.renderer, selectedTextFont, WHITE)
  # selectedTextObj = newTextObject(game.renderer, selectedTextFont, YELLOW)

  titleTextObj = newTextObject(game.renderer, mediumTextFont, WHITE)
  scoreTextObj = newTextObject(game.renderer, mediumTextFont, WHITE)

  selectedTextObj = newTextObject(game.renderer, selectedTextFont, YELLOW)

  firstEntererdTextObj = newTextObject(game.renderer, selectedTextFont, WHITE)

  secondEntererdTextObj = newTextObject(game.renderer, selectedTextFont, WHITE)
  thirdEntererdTextObj = newTextObject(game.renderer, selectedTextFont, WHITE)

  mediumLeftTextObj = newTextObject(game.renderer, mediumTextFont, WHITE)
  mediumRightTextObj = newTextObject(game.renderer, mediumTextFont, WHITE)

  smallLeftTextObj = newTextObject(game.renderer, smallTextFont, WHITE)
  smallRightTextObj = newTextObject(game.renderer, smallTextFont, WHITE)

  titleTextObj.setText("New High Score")
  titleTextObj.y = (CENTER_Y * 0.3).cint
  titleTextObj.x = SCREEN_W div 2
  titleTextObj.setPivot(0.5, 0.5)

  # TODO: replace hardcoding of score

  scoreTextObj.setText(playerScore)
  scoreTextObj.y = (CENTER_Y * 0.6).cint
  scoreTextObj.x = (SCREEN_W div 2 - len(playerScore)).cint
  scoreTextObj.setPivot(0.5, 0.5)

  # positioning of letters on screen

  firstEntererdTextObj.x = LEFT_UNDERSCORE_X + 30
  firstEntererdTextObj.y = TOP_UNDERSCORES_Y - 100

  secondEntererdTextObj.x = MIDDLE_UNDERSCORE_X + 30
  secondEntererdTextObj.y = TOP_UNDERSCORES_Y - 100

  thirdEntererdTextObj.x = RIGHT_UNDERSCORE_X + 30
  thirdEntererdTextObj.y = TOP_UNDERSCORES_Y - 100

  smallLeftTextObj.x = MIDDLE_UNDERSCORE_X - 90
  smallLeftTextObj.y = SELECTED_UNDERSCORE_Y - 75

  mediumLeftTextObj.x = MIDDLE_UNDERSCORE_X - 30
  mediumLeftTextObj.y = SELECTED_UNDERSCORE_Y - 95

  selectedTextObj.x = MIDDLE_UNDERSCORE_X + 30
  selectedTextObj.y = SELECTED_UNDERSCORE_Y - 125

  mediumRightTextObj.x = MIDDLE_UNDERSCORE_X + 110
  mediumRightTextObj.y = SELECTED_UNDERSCORE_Y - 95

  smallRightTextObj.x = MIDDLE_UNDERSCORE_X + 170
  smallRightTextObj.y = SELECTED_UNDERSCORE_Y - 75

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
  titleTextObj.render()
  scoreTextObj.render()

  game.renderArrow(leftArrowObj)
  game.renderArrow(rightArrowObj)

  game.renderUnderscore(leftUnderscoreObj)
  game.renderUnderscore(middleUnderscoreObj)
  game.renderUnderscore(rightUnderscoreObj)
  game.renderUnderscore(selectedUnderscoreObj)

  firstEntererdTextObj.renderLetter(currIndex + 17)
  secondEntererdTextObj.renderLetter(currIndex + 13)
  thirdEntererdTextObj.renderLetter(currIndex + 12)

  smallLeftTextObj.renderLetter(currIndex - 2)
  mediumLeftTextObj.renderLetter(currIndex - 1)
  selectedTextObj.renderLetter(currIndex)
  mediumRightTextObj.renderLetter(currIndex + 1)
  smallRightTextObj.renderLetter(currIndex + 2)

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
