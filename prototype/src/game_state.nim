include game_data

var state: GameData = (lives: 3, coins: 0, board: defaultBoard())

proc getGameState*(): GameData =
  result = (lives: state.lives, coins: state.coins, board: state.board)

proc updateGameState*(nextState: GameData) =
  state.lives = nextState.lives
  state.coins = nextState.coins
  state.board = nextState.board
