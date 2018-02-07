import game_types
import times
import mersenne
from strutils import repeat

var seed: uint32

proc nextRandom*(low: uint32, high: uint32): uint32 =
  ## obtains a pseudo-random number R >= low < high
  var mt = newMersenneTwister(seed)
  result = uint32(low + (mt.getNum() mod (high - low)))

proc getInitialState*(game: Game) =
  ## initializes the game's state with the initial state
  game.state.board = "S".repeat(100)
  game.state.lives = 3
  game.state.coins = 0
  seed = epochTime().uint32

proc resetBoardState*(game: Game) =
  ## reset the board state to all stones
  game.state.board = "S".repeat(100)

proc loseLife*(game: Game) =
  ## decrements number of remaining lives - will not go < 0
  dec(game.state.lives)
  if game.state.lives < 0:
    game.state.lives = 0

proc getBoardCell*(game: Game, x: int = 0, y: int = 0): char =
  ## gets the value of a single cell of the given board at the given optional coordinate
  let position:int = x + y * 10
  assert(position >= 0 and position < 100, "Cannot read cell outside of board boundaries")
  result = game.state.board[position]

proc setBoardCell*(game: Game, x: int, y: int, cell: char) =
  ## sets the value of a single cell of the given board at the given coordinate
  let position:int = x + y * 10
  assert(position >= 0 and position < 100, "Cannot write cell outside of board boundaries")
  game.state.board[position] = cell

proc clickBoardCell*(game: Game, x: int, y: int): BoardEvent =
  ## handles a click on a given board cell at a given position
  ## if the cell is a stone,
  ##   either dirt, pit, or coin will be uncovered
  ##   if a pit is uncovered,
  ##      game state lives will be decremented by 1
  ##      BoardEvent.foundPit will be returned
  ##   if dirt is uncovered, BoardEvent.foundDirt will be returned
  ##   if a coin is uncovered, BoardEvent.foundCoin will be returned
  ## else if the cell is a coin,
  ##   game state coins will be incremented by 1
  ##   the coin will be removed from the board and the cell changed to dirt
  ##   BoardEvent.takeCoin will be returned

  let currentCell = game.getBoardCell(x, y)

  if currentCell == 'S':
    let R = nextRandom(0, 2)
    let nextCell: char = "DPC"[R.int]
    game.setBoardCell(x, y, nextCell)
    if nextCell == 'P':
      game.loseLife()
      result = BoardEvent.foundPit
    elif nextCell == 'D':
      result = BoardEvent.foundDirt
    elif nextCell == 'C':
      result = BoardEvent.foundCoin
  elif currentCell == 'C':
    inc(game.state.coins)
    game.setBoardCell(x, y, 'D')
    result = BoardEvent.takeCoin
