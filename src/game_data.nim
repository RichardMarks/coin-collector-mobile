type
  GameCoordinate* = tuple[x: int, y: int]
  GameBoard* = array[100, char]
  GameData* = tuple
    lives: int
    coins: int
    board: GameBoard

template defaultBoard*():GameBoard =
  var board: GameBoard = [
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
  board
