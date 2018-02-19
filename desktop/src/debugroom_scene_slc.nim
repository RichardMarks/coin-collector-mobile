import sdl2, sdl2.ttf, sdl2.image
import game_types
import scene_management

import text_renderer
from game_state import getBoardCell, clickBoardCell, resetBoardState, STONE_TILE, DIRT_TILE, PIT_TILE, COIN_TILE
from game_input import wasClicked

import times
import mersenne
from strutils import repeat

# this creates a gap between the tiles of the board when rendering
const XADJUSTMENT: cint = 3
const YADJUSTMENT: cint = 8

# because of the spacing between the tiles, we have to calculate the adjusted rendered size
const BOARD_WIDTH_ADJUSTED: cint = BOARD_WIDTH + (XADJUSTMENT * BOARD_COLUMNS - 1) - 2
const BOARD_HEIGHT_ADJUSTED: cint = BOARD_HEIGHT + (YADJUSTMENT * BOARD_ROWS) + 13

# because we want the board to be rendered in the center of the screen, we have to use the adjusted values
const BOARD_X*: cint = cint((SCREEN_W - BOARD_WIDTH_ADJUSTED) div 2)
const BOARD_Y*: cint = cint((SCREEN_H - BOARD_HEIGHT_ADJUSTED) div 2)


type
  BoardData = string # array[BOARD_COLUMNS * BOARD_ROWS, char]

let backingRect: Rect = rect((SCREEN_W - 686) div 2, 90, 686, 540)
var
  tilesTexture: TexturePtr
  seed: uint32
  mt: MersenneTwister
  coinChance: int
  pitChance: int
  dirtChance: int
  possibilities: string

  # stones: array[BOARD_COLUMNS * BOARD_ROWS, tuple[]]

# element specific procedures
proc nextRandom*(low: uint32, high: uint32): uint32 {.inline.} =
  ## obtains a pseudo-random number R >= low < high
  result = uint32(low + (mt.getNum() mod (high - low)))

proc generateBoard(): BoardData =
  result = STONE_TILE.repeat(100)
  seed = epochTime().uint32
  mt = newMersenneTwister(seed)
  coinChance = nextRandom(5, 30).int
  pitChance = nextRandom(10, 40).int
  dirtChance = 100 - (coinChance + pitChance)
  possibilities = COIN_TILE.repeat(coinChance) & PIT_TILE.repeat(pitChance) & DIRT_TILE.repeat(dirtChance)
  for y in 0..<BOARD_ROWS:
    for x in 0..<BOARD_COLUMNS:
      result[x + y * BOARD_COLUMNS] = possibilities[nextRandom(0, 100).int]

let tileRects: array[4, Rect] = [
  rect(0, 0, 64, 64),
  rect(64, 0, 64, 64),
  rect(0, 64, 64, 64),
  rect(64, 64, 64, 64)
]

proc getTileClip(cell:char): Rect {.inline.} =
  case cell
  of STONE_TILE: result = tileRects[0]
  of DIRT_TILE: result = tileRects[1]
  of PIT_TILE: result = tileRects[2]
  of COIN_TILE: result = tileRects[3]
  else: discard

proc renderBoardStatic(game: Game, tick: float) =
  for y in 0..BOARD_YLIMIT:
    for x in 0..BOARD_XLIMIT:
      let cell = game.getBoardCell(x, y)
      var clip = cell.getTileClip()
      var dest = rect(BOARD_X + cint(x * (TILE_WIDTH + XADJUSTMENT)), BOARD_Y + cint(y * (Y_SPACE + YADJUSTMENT)), TILE_WIDTH, TILE_HEIGHT)
      game.renderer.copy(tilesTexture, unsafeAddr clip, unsafeAddr dest)

# life cycle procedures

proc registerDebugroomScene(scene: Scene, game: Game, tick: float) =
  tilesTexture = game.renderer.loadTexture("../tiles.png")
  sdlFailIf(tilesTexture.isNil): "Failed to load tiles.png"

proc destroyDebugroomScene(scene: Scene, game: Game, tick: float) =
  tilesTexture.destroy()

proc enterDebugroomScene(scene: Scene, game: Game, tick: float) =
  game.renderer.setDrawColor(r = 0x50, g = 0x90, b = 0x30)

  game.state.board = generateBoard()

proc exitDebugroomScene(scene: Scene, game: Game, tick: float) =
  discard

proc updateDebugroomScene(scene: Scene, game: Game, tick: float) =
  if game.wasClicked():
    game.state.board = generateBoard()

proc renderDebugroomScene(scene: Scene, game: Game, tick: float) =
  game.renderer.setDrawColor(r = 0x20, g = 0x20, b = 0x40)
  game.renderer.fillRect(unsafeAddr backingRect)
  game.renderer.setDrawColor(r = 0x50, g = 0x90, b = 0x30)
  renderBoardStatic(game, tick)

let debugroomSlc* = [
  registerDebugroomScene.SceneLifeCycleProc,
  enterDebugroomScene.SceneLifeCycleProc,
  updateDebugroomScene.SceneLifeCycleProc,
  renderDebugroomScene.SceneLifeCycleProc,
  exitDebugroomScene.SceneLifeCycleProc,
  destroyDebugroomScene.SceneLifeCycleProc]
