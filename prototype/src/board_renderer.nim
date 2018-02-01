from strutils import repeat
from terminal import setForegroundColor,
                     setBackgroundColor,
                     ForegroundColor,
                     BackgroundColor

proc renderBoard*(board: array[100, char]) =
  ## Takes the 10x10 char board array as input and
  ## outputs the board display to stdout
  setForegroundColor(fgWhite)
  setBackgroundColor(bgBlack)
  let n = char(0xa)
  stdout.write("---", "----".repeat(10), "  ", n, "  | ")
  for x in 0..9:
    stdout.write($x, " | ")
  stdout.write('X', n)
  stdout.write("--+", "---+".repeat(10), "  ", n)
  for y in 0..9:
    let row = char(y + 65)
    stdout.write(row, " |")
    for x in 0..9:
      let cell = board[x + y * 10]
      case cell
      of 'S':
        setForegroundColor(fgBlack)
        setBackgroundColor(bgBlack, bright = true)
      of 'D':
        setForegroundColor(fgBlue, bright = false)
        setBackgroundColor(bgGreen, bright = false)
      of 'P':
        setForegroundColor(fgBlack)
        setBackgroundColor(bgRed)
      of 'C':
        setForegroundColor(fgYellow, bright = true)
        setBackgroundColor(bgBlack, bright = true)
      else: discard
      stdout.write(' ', cell, ' ')
      setForegroundColor(fgWhite)
      setBackgroundColor(bgBlack)
      stdout.write('|')
    stdout.write("  ", n, "--+", "---+".repeat(10), "  ", n)
  stdout.write('Y', "    ".repeat(10), "    ", n)

when isMainModule:
  let board = [
    'S','S','S','S','S','S','S','S','S','S',
    'S','S','S','S','S','S','S','S','S','S',
    'S','S','S','S','S','S','S','S','S','S',
    'S','S','S','S','S','D','S','S','S','S',
    'S','S','S','S','S','S','S','D','S','S',
    'S','S','P','S','S','S','S','S','S','S',
    'S','S','S','S','P','S','S','S','C','S',
    'S','S','S','S','S','S','S','S','S','S',
    'S','S','S','S','C','S','S','S','S','S',
    'S','S','S','S','S','S','S','S','S','S'
  ]

  renderBoard(board)
