import random
from strutils import split, toUpperAscii, parseInt, `%`

from game_state import updateGameState, getGameState
from board_renderer import renderBoard
from board_logic import processInteraction
from command_panel import renderCommandPanel
from header_renderer import renderHeader

include game_data

# proc renderHeader(game:GameData) =
#   echo "lives: $1, coins: $2" % [$game.lives, $game.coins]

proc runGameLoop*() =
  ## runs the game session logic loop
  updateGameState((lives: 3, coins: 0, board: defaultBoard()))
  while true:
    let gameState = getGameState()
    renderHeader(gameState)
    renderBoard(gameState.board)
    let coords = renderCommandPanel()
    let state = processInteraction(gameState, coords)
    updateGameState(state)
    if state.lives <= 0:
      break
