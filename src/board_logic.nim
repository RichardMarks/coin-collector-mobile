include game_data

let initialBoard*:GameBoard = [
  'S','S','S','S','S','S','S','S','S','S',
  'S','S','S','S','S','S','S','S','S','S',
  'S','S','S','S','S','S','S','S','S','S',
  'S','S','S','S','S','S','S','S','S','S',
  'S','S','S','S','S','S','S','S','S','S',
  'S','S','P','S','S','S','S','S','S','S',
  'S','S','S','S','S','S','S','S','S','S',
  'S','S','S','S','S','S','S','S','S','S',
  'S','S','S','S','S','S','S','S','S','S',
  'S','S','S','S','S','S','S','S','S','S'
]

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

when isMainModule:
  var board = initialBoard
  let cell = board.getCell()
  echo cell, repr(cell)
  board.setCell(5, 5,'C')
  echo repr(board), board.getCell(5, 5)
