import random
from strutils import split, toUpperAscii, parseInt, `%`

from game_state import updateGameState, getGameState
from board_renderer import renderBoard
from board_logic import getCell, setCell, initialBoard

include game_data

proc processCommandPanelInput(game:GameData, coords: GameCoordinate): GameData =
  result = game
  randomize()
  let currentCell = game.board.getCell(coords.x, coords.y)
  case currentCell:
    of 'S':
      let nextCell = "DPC".random()
      case nextCell:
        of 'P': dec(result.lives)
        of 'C': inc(result.coins)
        else: discard
      result.board.setCell(coords.x, coords.y, nextCell)
    of 'C':
      inc(result.coins)
      result.board.setCell(coords.x, coords.y, 'D')
    else: discard

proc renderHeader(game:GameData) =
  echo "lives: $1, coins: $2" % [$game.lives, $game.coins]

proc renderCommandPanel(game:GameData): GameCoordinate =
  echo "coord? (Y,X) "
  let input = stdin.readLine().toUpperAscii
  let pair = input.split(',')
  let cx = parseInt(pair[1])
  let cy = int(char(pair[0][0])) - 65
  echo repr((input, pair, cx, cy))
  result = (x: cx, y: cy)

proc gameLoop() =
  while true:
    let gameState = getGameState()
    renderHeader(gameState)
    renderBoard(gameState.board)
    let coords = renderCommandPanel(gameState)
    let state = processCommandPanelInput(gameState, coords)
    # echo repr(state)
    updateGameState(state)
    if state.lives <= 0:
      break

proc mainLoop*() =
  while true:
    updateGameState((lives: 3, coins: 0, board: defaultBoard()))
    gameLoop()
    echo "*** G A M E  O V E R ***"
    echo "Play Again? (Y/N) "
    case stdin.readLine():
      of "n", "N", "no", "NO", "No": break
      else: discard

when isMainModule:
  mainLoop()
