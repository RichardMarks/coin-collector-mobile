import random
include game_data

proc getCell*(board: GameBoard, x: int = 0, y: int = 0): char =
  ## gets the value of a single cell of the given board at the given optional coordinate
  let position:int = x + y * 10
  assert(position >= 0 and position < 100, "Cannot read cell outside of board boundaries")
  result = board[position]

proc setCell*(board: var GameBoard, x: int, y: int, cell: char) =
  ## sets the value of a single cell of the given board at the given coordinate
  let position:int = x + y * 10
  assert(position >= 0 and position < 100, "Cannot write cell outside of board boundaries")
  board[position] = cell

proc processInteraction*(game:GameData, coords: GameCoordinate): GameData =
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

when isMainModule:
  var board = defaultBoard()
  let cell = board.getCell()
  echo cell, repr(cell)
  board.setCell(5, 5,'C')
  echo repr(board), board.getCell(5, 5)
