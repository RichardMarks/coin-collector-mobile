import random
from strutils import split, toUpperAscii, parseInt, `%`

from game_state import updateGameState, getGameState
from board_renderer import renderBoard
from board_logic import processInteraction

include game_data

proc renderHeader(game:GameData) =
  echo "lives: $1, coins: $2" % [$game.lives, $game.coins]

proc renderCommandPanel(game:GameData): GameCoordinate =
  echo "Y,X: "
  let input = stdin.readLine().toUpperAscii
  let pair = input.split(',')
  let cx = parseInt(pair[1])
  let cy = int(char(pair[0][0])) - 65
  result = (x: cx, y: cy)

proc runGameLoop*() =
  updateGameState((lives: 3, coins: 0, board: defaultBoard()))
  while true:
    let gameState = getGameState()
    renderHeader(gameState)
    renderBoard(gameState.board)
    let coords = renderCommandPanel(gameState)
    let state = processInteraction(gameState, coords)
    updateGameState(state)
    if state.lives <= 0:
      break
