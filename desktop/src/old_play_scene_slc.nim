import sdl2
import sdl2.image
import game_types
import scene_management

from text_renderer import TextObject, newTextObject, render, setText, setColor, setPivot, setScale, containsPoint, getWidth, getHeight
from game_input import wasClicked
from game_state import getBoardCell, clickBoardCell, resetBoardState, STONE_TILE, DIRT_TILE, PIT_TILE, COIN_TILE

# this creates a gap between the tiles of the board when rendering
const XADJUSTMENT: cint = 3
const YADJUSTMENT: cint = 8

# because of the spacing between the tiles, we have to calculate the adjusted rendered size
const BOARD_WIDTH_ADJUSTED: cint = BOARD_WIDTH + (XADJUSTMENT * BOARD_COLUMNS)
const BOARD_HEIGHT_ADJUSTED: cint = BOARD_HEIGHT + (YADJUSTMENT * BOARD_ROWS)

# because we want the board to be rendered in the center of the screen, we have to use the adjusted values
const BOARD_X*: cint = cint((SCREEN_W - BOARD_WIDTH_ADJUSTED) div 2)
const BOARD_Y*: cint = cint((SCREEN_H - BOARD_HEIGHT_ADJUSTED) div 2)

type
  PlayMode = enum starting, playing, paused

  PlayButton = enum
    none,
    menu

var
  playMode: PlayMode = PlayMode.starting

  activeButton: PlayButton = PlayButton.none

  tilesTexture: TexturePtr

  elapsedTime: float
  dimmerTexture: TexturePtr
  dimmerRect: Rect
  playTime: float

let regionRects: array[2, Rect] = [
  rect(BOARD_X, BOARD_Y, BOARD_WIDTH_ADJUSTED.cint, BOARD_HEIGHT_ADJUSTED.cint),
  rect(0, 0, 120, 40)
]

const PAUSE_FLASH_DELAY = 0.7
var
  pauseFlashTime: float = 0
  pauseShow: bool = true
  pauseText: TextObject

proc registerPlayScene(scene: Scene, game: Game, tick: float) =
  discard

proc destroyPlayScene(scene: Scene, game: Game, tick: float) =
  discard

proc enterPlayScene(scene: Scene, game: Game, tick: float) =
  discard

proc exitPlayScene(scene: Scene, game: Game, tick: float) =
  discard

proc updateStartingPlayMode(scene: Scene, game: Game, tick: float) =
  discard

proc updatePlayingPlayMode(scene: Scene, game: Game, tick: float) =
  discard

proc updatePausedPlayMode(scene: Scene, game: Game, tick: float) =
  discard

proc renderStartingPlayMode(scene: Scene, game: Game, tick: float) =
  discard

proc renderPlayingPlayMode(scene: Scene, game: Game, tick: float) =
  discard

proc renderPausedPlayMode(scene: Scene, game: Game, tick: float) =
  if pauseFlashTime >= PAUSE_FLASH_DELAY:
    pauseFlashTime -= PAUSE_FLASH_DELAY
    pauseShow = not pauseShow
  if pauseShow:
    pauseText.render()

proc drawHUD(game: Game, tick: float) =
  let
    lives: string = $game.state.lives
    coins: string = $game.state.coins
    timer: string = $game.state.timer

  const HUD_Y = 35
  game.renderTextCached("LIVES: " & lives,  325, HUD_Y, WHITE)
  game.renderTextCached("SCORE: " & coins, 325, HUD_Y + 35, WHITE)
  game.renderTextCached("TIME: " & timer, 800, HUD_Y, WHITE)

proc onClick(game: Game) =
  let mx = game.mouse.x
  let my = game.mouse.y

  # echo "mx: " & $mx, "my: " & $my

  if (playMode == PlayMode.start or playMode == PlayMode.pause):
    playMode = PlayMode.play
    return

  if activeButton == PauseButton.pauseMode:
    playMode = PlayMode.pause
    return

  if regionRects[0].contains(point(mx, my)):
    # clicked on board
    let x: int = (mx - BOARD_X) div (TILE_WIDTH + XADJUSTMENT)
    let y: int = (my - BOARD_Y) div (Y_SPACE + YADJUSTMENT)
    # echo "clicking tile @[" & $x & ", " & $y & "]"
    let boardEvent = game.clickBoardCell(x, y)
    case boardEvent
    of BoardEvent.foundDirt: echo "found dirt!"
    of BoardEvent.foundPit: echo "found a pit and lost a life!"
    of BoardEvent.foundCoin: echo "found a coin"
    of BoardEvent.takeCoin: echo "picked up a coin!"
    if game.state.lives == 0:
      echo "lost all lives. game over man"
      game.sceneManager.enter("gameover")
    elif game.state.board.contains('S') == false:
      echo "all tiles flipped, need to reset the board"
      game.resetBoardState()
  elif regionRects[1].contains(point(mx, my)):
    # clicked on quit button
    game.sceneManager.enter("title")

proc getTileClip(cell:char): Rect =
  case cell
  of STONE_TILE: result = rect(0, 0, 64, 64)
  of DIRT_TILE: result = rect(64, 0, 64, 64)
  of PIT_TILE: result = rect(0, 64, 64, 64)
  of COIN_TILE: result = rect(64, 64, 64, 64)
  else: discard

proc registerPlayScene(scene: Scene, game: Game, tick: float) =
  # load assets here
  tilesTexture = game.renderer.loadTexture("../tiles.png")

  # create a 2x2 texture, fill it with black, enable alpha blend mode
  dimmerTexture = createTexture(game.renderer, SDL_PIXELFORMAT_ABGR8888, SDL_TEXTUREACCESS_STATIC, 2, 2)
  if dimmerTexture.isNil:
    raise SystemError.newException("Failed to create dimmerTexture")

  var blackFill: array[4, tuple[r,g,b,a:uint8]] = [
    (0'u8, 0'u8, 0'u8, 0xFF'u8),
    (0'u8, 0'u8, 0'u8, 0xFF'u8),
    (0'u8, 0'u8, 0'u8, 0xFF'u8),
    (0'u8, 0'u8, 0'u8, 0xFF'u8)
  ]
  dimmerTexture.updateTexture(nil, addr blackFill, (sizeof(Color) * 2).cint)
  dimmerTexture.setTextureBlendMode(BlendMode_Blend)

  # we will render the 2x2 texture to stretch across the whole screen
  dimmerRect = rect(0, 0, SCREEN_W, SCREEN_H)

proc enterPlayScene(scene: Scene, game: Game, tick: float) =
  # enter animation / show play scene here

  # game.renderer.setDrawColor(r = 0x30, g = 0x50, b = 0x90)
  game.renderer.setDrawColor(r = 0x00, g = 0x00, b = 0x00)
  elapsedTime = 0

var labelColor: Color = WHITE
proc renderButton(game: Game, label: string, x, y: int, isActive: bool) =
  ## renders a button (white text label by default, yellow text label for hover)
  if isActive:
    labelColor = YELLOW
  game.renderTextCached(label, x.cint, y.cint, labelColor)


proc updatePlayScene(scene: Scene, game: Game, tick: float) =
  # called on game update proc
  elapsedTime += tick

  let mx = game.mouse.x
  let my = game.mouse.y
  activeButton = PauseButton.none
  if mx >= 95 and mx <= 256 and my >= 300 and my <= 329:
    activeButton = PauseButton.pauseMode

  case playMode
  of PlayMode.play:

      # echo "in box, activeButton: ", activeButton
    playTime += tick
    if playTime >= 1:
      playTime = 0
      game.state.timer -= 1
      if game.state.timer <= 0:
        game.state.timer = 0
        game.sceneManager.enter("gameover")
  else: discard

  if game.wasClicked():
    game.onClick()

proc drawStartState(game: Game, tick: float) =
  if (elapsedTime * 30).int div 10 mod 2 == 0:
    game.renderTextCached("Touch to Start", 560, 360, WHITE)
  else:
    game.renderTextCached("Touch to Start", 560, 360, YELLOW)

proc drawPauseState(game: Game) =
  game.renderTextCached("P A U S E D", 560, 360, WHITE)

proc drawPlayState(game: Game) =
  # called on play mode
  for y in 0..BOARD_YLIMIT:
    for x in 0..BOARD_XLIMIT:
      let cell = game.getBoardCell(x, y)
      var clip = cell.getTileClip()
      var dest = rect(BOARD_X + cint(x * (TILE_WIDTH + XADJUSTMENT)), BOARD_Y + cint(y * (Y_SPACE + YADJUSTMENT)), TILE_WIDTH, TILE_HEIGHT)
      game.renderer.copy(tilesTexture, unsafeAddr clip, unsafeAddr dest)

proc renderPlayScene(scene: Scene, game: Game, tick: float) =
  # called on game render proc
  case playMode:
  of PlayMode.start:
    game.drawPlayState()
    game.drawHUD(tick)
    game.renderButton("Pause Game", 100, 300, false)
    # draw a dimmer texture to fill the screen at 120% opacity
    dimmerTexture.setTextureAlphaMod(120)
    copy(game.renderer, dimmerTexture, nil, addr dimmerRect)
    game.drawStartState(tick)
  of PlayMode.play:
    game.drawPlayState()
    game.drawHUD(tick)
    game.renderButton("Pause Game", 100, 300, activeButton == PauseButton.pauseMode)

  of PlayMode.pause:
    game.drawPlayState()
    game.drawHUD(tick)
    # game.renderButton("Pause Game", 100, 300, false)

    # draw a dimmer texture to fill the screen at 120% opacity
    dimmerTexture.setTextureAlphaMod(120)
    copy(game.renderer, dimmerTexture, nil, addr dimmerRect)
    game.drawPauseState()
  else:
    discard

  # debugging
  var mx = game.mouse.x
  var my = game.mouse.y
  game.renderTextCached("" & $mx & ", " & $my, (mx + 32).cint, (my - 32).cint, WHITE)

proc exitPlayScene(scene: Scene, game: Game, tick: float) =
  # exit animation / leave play scene here
  discard

proc destroyPlayScene(scene: Scene, game: Game, tick: float) =
  # release assets here, like at game end
  destroyTexture(tilesTexture)

let playSlc* = [
  registerPlayScene.SceneLifeCycleProc,
  enterPlayScene.SceneLifeCycleProc,
  updatePlayScene.SceneLifeCycleProc,
  renderPlayScene.SceneLifeCycleProc,
  exitPlayScene.SceneLifeCycleProc,
  destroyPlayScene.SceneLifeCycleProc]
