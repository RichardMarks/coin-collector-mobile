type
  HighScoreTableHeader* = tuple
    fourcc: array[4, char]
    numScores: uint32
  HighScoreEntry* = tuple
    initials: array[4, char]
    score: uint32
  
  # assumes the binary file read from is the same size as this table structure
  HighScoreTable* = tuple
    header: HighScoreTableHeader
    data: array[10, HighScoreEntry]

const HIGH_SCORES_DB: string = "hiscore.tbl"

proc writeNewHighScore*(newPlayerHighScore: HighScoreEntry, filename: string = HIGH_SCORES_DB) =
  # assumes file will already exist, "old school programmers' high scores" apparently...
  var fp = open(filename, fmRead)
  var table: HighScoreTable
  defer: 
    fp.close()

  var bytesRead: int = readBuffer(fp, addr table, sizeof(table))
  if bytesRead != sizeof(table):
    raise SystemError.newException("Invalid high score table")
  var pos: int = 0
  while pos < 10:
    if table.data[pos].score < newPlayerHighScore.score:
      # echo "position to insert is " & $pos
      for i in 0..<(9 - pos):
        var dst: int = 9 - i
        var src: int = 9 - (i + 1)
        # echo "shift from " & $src & " to " & $dst
        table.data[dst] = table.data[src]
      table.data[pos] = newPlayerHighScore
      break
    pos += 1
  # echo $table.data[0..<10]
  fp.close()
  var fpW = open(filename, fmWrite)

  defer:
    fpW.close()

  var bytesWritten: int = writeBuffer(fpW, addr table, sizeof(table))
  if (bytesWritten == 0):
    raise SystemError.newException("No high scores table data written")

proc loadHighScores*(filename: string = HIGH_SCORES_DB): HighScoreTable =
  var fp = open(filename, fmRead)
  var table: HighScoreTable
  var bytesRead: int = readBuffer(fp, addr table, sizeof(table))
  echo "bytesRead: ", bytesRead
  echo "sizeof(table): ", sizeof(table)
  if bytesRead != sizeof(table):
    raise SystemError.newException("Invalid high score table")
  
  defer: 
    fp.close()
  result = table

proc isTopTenScore*(playerGameScore: uint32): bool =
  var table: HighScoreTable = loadHighScores()
  result = false
  for score in table.data:
    # echo $score.initials[0..2] & " - " & $score.score
    if score.score < playerGameScore:
      result = true
      break


when isMainModule:

  # writeNewHighScore(HIGH_SCORES_FILE)
  # # var fp = open("hiscore.tbl", fmRead)
  # # defer: fp.close()
  # # var table: HighScoreTable
  # # var bytesRead: int = readBuffer(fp, addr table, sizeof(table))
  # # if bytesRead != sizeof(table):
  # #   raise SystemError.newException("Invalid high score table")
  # echo $table.header.fourcc[0..3]
  # echo $table.header.numScores
  # for score in table.data:
    # echo $score.initials[0..2] & " - " & $score.score
  # var scores: array[10, int] = [1000, 500, 400, 200, 100, 50, 20, 10, 5, 1]
  # const newPlayerScore: HighScoreEntry = (['A','F','K', '\0'], 84.uint32)
  # # echo $table.data[0..<10]
  # writeNewHighScore(HIGH_SCORES_FILE,newPlayerScore)

  var table: HighScoreTable = loadHighScores()
  for score in table.data:
    echo $score.initials[0..2] & " - " & $score.score

  # var score: int = 250
  # var pos: int = 0
  # while pos < 10:
  #   if table.data[pos].score < newPlayerScore.score:
  #     echo "position to insert is " & $pos
  #     for i in 0..<(9 - pos):
  #       var dst: int = 9 - i
  #       var src: int = 9 - (i + 1)
  #       echo "shift from " & $src & " to " & $dst
  #       table.data[dst] = table.data[src]
  #     table.data[pos] = newPlayerScore
  #     break
  #   pos += 1
  # echo $table.data[0..<10]
  
  # var scores: array[10, int] = [1000, 500, 400, 200, 100, 50, 20, 10, 5, 1]
  # echo $scores[0..<10]
  # var score: int = 250
  # var pos: int = 0
  # while pos < 10:
  #   if scores[pos] < score:
  #     echo "position to insert is " & $pos
  #     for i in 0..<(9 - pos):
  #       var dst: int = 9 - i
  #       var src: int = 9 - (i + 1)
  #       echo "shift from " & $src & " to " & $dst
  #       scores[dst] = scores[src]
  #     scores[pos] = score
  #     break
  #   pos += 1
  # echo $scores[0..<10]