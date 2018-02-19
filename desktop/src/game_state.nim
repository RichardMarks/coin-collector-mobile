import game_types
import times
import mersenne
from strutils import repeat, `%`

const STONE_TILE* = 'S'
const DIRT_TILE* = 'D'
const PIT_TILE* = 'P'
const COIN_TILE* = 'C'

var
  seed: uint32
  mt: MersenneTwister
  coinChance: int
  pitChance: int
  dirtChance: int

proc nextRandom*(low: uint32, high: uint32): uint32 =
  ## obtains a pseudo-random number R >= low < high
  result = uint32(low + (mt.getNum() mod (high - low)))

proc resetBoardState*(game: Game) =
  ## reset the board state to all stones, and calculates a new probability for outcome
  game.state.board = STONE_TILE.repeat(100)
  coinChance = nextRandom(5, 30).int
  pitChance = nextRandom(10, 40).int
  dirtChance = 100 - (coinChance + pitChance)

proc getInitialState*(game: Game) =
  ## initializes the game's state with the initial state
  game.resetBoardState()
  game.state.lives = 3
  game.state.coins = 0
  game.state.timer = 60
  seed = epochTime().uint32
  mt = newMersenneTwister(seed)

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

proc getNextCell(): char =
  ## determines what kind of cell will be uncovered - used internally by clickBoardCell

  let roll = nextRandom(0, 100).int

  # echo "chance is coin $1% pit $2% dirt $3%" % [$coinChance, $pitChance, $dirtChance]
  # echo "roll is " & $roll

  let chance = COIN_TILE.repeat(coinChance) & PIT_TILE.repeat(pitChance) & DIRT_TILE.repeat(dirtChance)
  result = chance[roll]

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

  if currentCell == STONE_TILE:
    let nextCell = getNextCell()
    game.setBoardCell(x, y, nextCell)
    if nextCell == PIT_TILE:
      game.loseLife()
      result = BoardEvent.foundPit
    elif nextCell == DIRT_TILE:
      result = BoardEvent.foundDirt
    elif nextCell == COIN_TILE:
      result = BoardEvent.foundCoin
  elif currentCell == COIN_TILE:
    inc(game.state.coins)
    game.setBoardCell(x, y, DIRT_TILE)
    result = BoardEvent.takeCoin
  else:
    result = BoardEvent.noop
