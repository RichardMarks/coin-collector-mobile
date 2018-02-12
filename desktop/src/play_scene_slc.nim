import sdl2, sdl2.ttf, sdl2.image
import game_types
import scene_management

import text_renderer
from game_input import wasClicked
from game_state import getBoardCell, clickBoardCell, resetBoardState, STONE_TILE, DIRT_TILE, PIT_TILE, COIN_TILE

# this creates a gap between the tiles of the board when rendering
const XADJUSTMENT: cint = 3
const YADJUSTMENT: cint = 8

# because of the spacing between the tiles, we have to calculate the adjusted rendered size
const BOARD_WIDTH_ADJUSTED: cint = BOARD_WIDTH + (XADJUSTMENT * BOARD_COLUMNS - 1) - 2
const BOARD_HEIGHT_ADJUSTED: cint = BOARD_HEIGHT + (YADJUSTMENT * BOARD_ROWS) + 13

# because we want the board to be rendered in the center of the screen, we have to use the adjusted values
const BOARD_X*: cint = cint((SCREEN_W - BOARD_WIDTH_ADJUSTED) div 2)
const BOARD_Y*: cint = cint((SCREEN_H - BOARD_HEIGHT_ADJUSTED) div 2)

const PAUSE_FLASH_DELAY = 0.7
const CENTER_X = SCREEN_W div 2
const CENTER_Y = SCREEN_H div 2

type
  PlayMode = enum starting, playing, paused

  PlayButton = enum
    none,
    menu,
    resumeGame,
    quitGame

let
  backingRect: Rect = rect((SCREEN_W - 686) div 2, 90, 686, 540)
  boardRect:Rect = rect(BOARD_X, BOARD_Y, BOARD_WIDTH_ADJUSTED.cint, BOARD_HEIGHT_ADJUSTED.cint)

var
  playMode: PlayMode = PlayMode.starting
  activeButton: PlayButton = PlayButton.none
  menuText: TextObject
  resumeText: TextObject
  quitText: TextObject
  pauseText: TextObject
  hudTimeText: TextObject
  hudScoreText: TextObject
  hudLivesText: TextObject
  startText: TextObject
  hudFont: FontPtr
  messageFont: FontPtr
  tilesTexture: TexturePtr
  dimmerTexture: TexturePtr
  dimmerRect: Rect
  pauseFlashTime: float = 0
  pauseShow: bool = true
  gameTime: float = 0

# element specific procedures

proc renderButton(textObj: TextObject, matchActive: PlayButton) =
  if matchActive == activeButton:
    textObj.setColor(YELLOW)
  else:
    textObj.setColor(WHITE)
  textObj.render()

proc getTileClip(cell:char): Rect =
  case cell
  of STONE_TILE: result = rect(0, 0, 64, 64)
  of DIRT_TILE: result = rect(64, 0, 64, 64)
  of PIT_TILE: result = rect(0, 64, 64, 64)
  of COIN_TILE: result = rect(64, 64, 64, 64)
  else: discard

proc renderBoardStatic(game: Game, tick: float) =
  for y in 0..BOARD_YLIMIT:
    for x in 0..BOARD_XLIMIT:
      let cell = game.getBoardCell(x, y)
      var clip = cell.getTileClip()
      var dest = rect(BOARD_X + cint(x * (TILE_WIDTH + XADJUSTMENT)), BOARD_Y + cint(y * (Y_SPACE + YADJUSTMENT)), TILE_WIDTH, TILE_HEIGHT)
      game.renderer.copy(tilesTexture, unsafeAddr clip, unsafeAddr dest)

proc renderBoardAnimated(game: Game, tick: float) =
  # TODO: implement board building animation
  renderBoardStatic(game, tick)

proc renderDimmer(game: Game) =
  dimmerTexture.setTextureAlphaMod(120)
  copy(game.renderer, dimmerTexture, nil, addr dimmerRect)

proc renderHUD(game: Game, tick: float) =
  hudScoreText.render()
  hudTimeText.render()
  hudLivesText.render()

proc renderPauseMenu(game: Game) =
  resumeText.renderButton(PlayButton.resumeGame)
  quitText.renderButton(PlayButton.quitGame)

proc handleFoundDirtBoardEvent(game: Game, mx, my: cint) = discard

proc handleFoundPitBoardEvent(game: Game, mx, my: cint) =
  hudLivesText.setText("Lives: " & $game.state.lives)
  if game.state.lives == 0:
    game.sceneManager.enter("gameover")

proc handleFoundCoinBoardEvent(game: Game, mx, my: cint) = discard

proc handleTakeCoinBoardEvent(game: Game, mx, my: cint) =
  var label: string = "Score: " & $game.state.coins
  echo game.state.coins
  echo label
  hudScoreText.setText(label)

proc handleBoardUpdate(game: Game, mx, my: cint) =
  # clicked on board
  let x: int = (mx - BOARD_X) div (TILE_WIDTH + XADJUSTMENT)
  let y: int = (my - BOARD_Y) div (Y_SPACE + YADJUSTMENT)
  # echo "clicking tile @[" & $x & ", " & $y & "]"
  let boardEvent = game.clickBoardCell(x, y)
  case boardEvent
  of BoardEvent.foundDirt: handleFoundDirtBoardEvent(game, mx, my)
  of BoardEvent.foundPit: handleFoundPitBoardEvent(game, mx, my)
  of BoardEvent.foundCoin: handleFoundCoinBoardEvent(game, mx, my)
  of BoardEvent.takeCoin: handleTakeCoinBoardEvent(game, mx, my)
  else: discard

  if game.state.board.contains('S') == false:
    echo "all tiles flipped, need to reset the board"
    game.resetBoardState()

proc updateGameTimer(game: Game, tick: float): bool =
  result = false
  gameTime += tick
  if gameTime >= 1.0:
    gameTime = 0
    game.state.timer -= 1
    if game.state.timer < 0:
      game.state.timer = 0
      result = true
    hudTimeText.setText("Time: " & $game.state.timer)


# life cycle procedures

proc registerPlayScene(scene: Scene, game: Game, tick: float) =
  hudFont = openFont("../monofonto.ttf", 32)
  sdlFailIf(hudFont.isNil): "Failed to load Imperator.ttf"

  messageFont = openFont("../talacha.ttf", 64)
  sdlFailIf(messageFont.isNil): "Failed to load Imperator.ttf"

  tilesTexture = game.renderer.loadTexture("../tiles.png")
  sdlFailIf(tilesTexture.isNil): "Failed to load tiles.png"

  # create a 2x2 texture, fill it with black, enable alpha blend mode
  dimmerTexture = createTexture(game.renderer, SDL_PIXELFORMAT_ABGR8888, SDL_TEXTUREACCESS_STATIC, 2, 2)
  if dimmerTexture.isNil:
    raise SystemError.newException("Failed to create dimmerTexture")

  var blackFill: array[4, tuple[r, g, b, a: uint8]] = [
    (0'u8, 0'u8, 0'u8, 0xFF'u8),
    (0'u8, 0'u8, 0'u8, 0xFF'u8),
    (0'u8, 0'u8, 0'u8, 0xFF'u8),
    (0'u8, 0'u8, 0'u8, 0xFF'u8)
  ]
  dimmerTexture.updateTexture(nil, addr blackFill, (sizeof(Color) * 2).cint)
  dimmerTexture.setTextureBlendMode(BlendMode_Blend)

  # we will render the 2x2 texture to stretch across the whole screen
  dimmerRect = rect(0, 0, SCREEN_W, SCREEN_H)

  menuText = newTextObject(game.renderer, game.menuItemFont, WHITE)
  resumeText = newTextObject(game.renderer, game.menuItemFont, WHITE)
  quitText = newTextObject(game.renderer, game.menuItemFont, WHITE)
  pauseText = newTextObject(game.renderer, messageFont, WHITE)
  hudTimeText = newTextObject(game.renderer, hudFont, WHITE)
  hudScoreText = newTextObject(game.renderer, hudFont, WHITE)
  hudLivesText = newTextObject(game.renderer, hudFont, WHITE)
  startText =  newTextObject(game.renderer, messageFont, WHITE)

  menuText.setText("menu")
  resumeText.setText("resume")
  quitText.setText("quit")
  pauseText.setText("P A U S E D")
  startText.setText("Click to Play")
  hudTimeText.setText("Time: 60")
  hudScoreText.setText("Score: 0")
  hudLivesText.setText("Lives: 3")

  menuText.setPivot(0.5, 1.0)
  menuText.x = CENTER_X
  menuText.y = SCREEN_H - 20

  startText.setPivot(0.5, 0.5)
  startText.y = CENTER_Y
  startText.x = CENTER_X

  pauseText.setPivot(0.5, 0.5)
  pauseText.y = CENTER_Y - (20 + pauseText.getHeight())
  pauseText.x = CENTER_X

  resumeText.setPivot(0.5, 0.5)
  resumeText.x = CENTER_X
  resumeText.y = pauseText.y + (20 + resumeText.getHeight())

  quitText.setPivot(0.5, 0.5)
  quitText.x = CENTER_X
  quitText.y = resumeText.y + (20 + quitText.getHeight())

  hudScoreText.setPivot(0.5, 1.0)
  hudScoreText.x = CENTER_X
  hudScoreText.y = BOARD_Y - 20

  hudLivesText.setPivot(1.0, 1.0)
  hudLivesText.y = hudScoreText.y
  hudLivesText.x = BOARD_X - 20

  hudTimeText.setPivot(0, 1.0)
  hudTimeText.y = hudScoreText.y
  hudTimeText.x = BOARD_X + BOARD_WIDTH_ADJUSTED + 20

proc destroyPlayScene(scene: Scene, game: Game, tick: float) =
  tilesTexture.destroy()
  hudFont.close()
  messageFont.close()

proc enterPlayScene(scene: Scene, game: Game, tick: float) =
  game.renderer.setDrawColor(r = 0x50, g = 0x50, b = 0x90)
  gameTime = 0
  playMode = PlayMode.starting
  hudTimeText.setText("Time: 60")
  hudScoreText.setText("Score: 0")
  hudLivesText.setText("Lives: 3")

proc exitPlayScene(scene: Scene, game: Game, tick: float) =
  discard

proc updateStartingPlayMode(scene: Scene, game: Game, tick: float) =
  if game.wasClicked():
    playMode = PlayMode.playing

proc updatePlayingPlayMode(scene: Scene, game: Game, tick: float) =
  let mx: cint = game.mouse.x.cint
  let my: cint = game.mouse.y.cint

  if menuText.containsPoint(mx, my): activeButton = PlayButton.menu
  else: activeButton = PlayButton.none

  if updateGameTimer(game, tick):
    game.sceneManager.enter("gameover")

  if game.wasClicked():
    if boardRect.contains(point(mx, my)):
      handleBoardUpdate(game, mx, my)
    elif menuText.containsPoint(mx, my):
      playMode = PlayMode.paused

proc updatePausedPlayMode(scene: Scene, game: Game, tick: float) =
  let mx: cint = game.mouse.x.cint
  let my: cint = game.mouse.y.cint

  if resumeText.containsPoint(mx, my): activeButton = PlayButton.resumeGame
  elif quitText.containsPoint(mx, my): activeButton = PlayButton.quitGame
  else: activeButton = PlayButton.none

  pauseFlashTime += tick
  if pauseFlashTime >= PAUSE_FLASH_DELAY:
    pauseFlashTime -= PAUSE_FLASH_DELAY
    pauseShow = not pauseShow

  if game.wasClicked():
    case activeButton
    of PlayButton.resumeGame: playMode = PlayMode.playing
    of PlayButton.quitGame: game.sceneManager.enter("title")
    else: discard

proc renderStartingPlayMode(scene: Scene, game: Game, tick: float) =
  renderBoardAnimated(game, tick)
  renderHUD(game, tick)
  renderDimmer(game)
  startText.render()

proc renderPlayingPlayMode(scene: Scene, game: Game, tick: float) =
  renderBoardStatic(game, tick)
  renderHUD(game, tick)
  menuText.renderButton(PlayButton.menu)

proc renderPausedPlayMode(scene: Scene, game: Game, tick: float) =
  renderBoardStatic(game, tick)
  renderDimmer(game)
  renderHUD(game, tick)
  renderPauseMenu(game)

  if pauseShow:
    pauseText.render()

proc updatePlayScene(scene: Scene, game: Game, tick: float) =
  case playMode
  of starting: updateStartingPlayMode(scene, game, tick)
  of playing: updatePlayingPlayMode(scene, game, tick)
  of paused: updatePausedPlayMode(scene, game, tick)

proc renderPlayScene(scene: Scene, game: Game, tick: float) =
  game.renderer.setDrawColor(r = 0x20, g = 0x20, b = 0x40)
  game.renderer.fillRect(unsafeAddr backingRect)
  game.renderer.setDrawColor(r = 0x50, g = 0x50, b = 0x90)
  case playMode
  of starting: renderStartingPlayMode(scene, game, tick)
  of playing: renderPlayingPlayMode(scene, game, tick)
  of paused: renderPausedPlayMode(scene, game, tick)

let playSlc* = [
  registerPlayScene.SceneLifeCycleProc,
  enterPlayScene.SceneLifeCycleProc,
  updatePlayScene.SceneLifeCycleProc,
  renderPlayScene.SceneLifeCycleProc,
  exitPlayScene.SceneLifeCycleProc,
  destroyPlayScene.SceneLifeCycleProc]
