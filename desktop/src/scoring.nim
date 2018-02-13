import streams
import algorithm
import game_types

const DATA_FILE* = "./desktop/src/data_file.dat"

proc newHighScore*(name: string, score: int): HighScoreTuple =
  new result
  result[0] = name
  result[1] = score

proc sortHighScoreList(highScoreList: var HighScoreList) =
  highScoreList.sort(proc( scoreTuple1,scoreTuple2: HighScoreTuple): int =
    result = cmp(scoreTuple2[1], scoreTuple1[1])
    if result == 0:
      result = cmp(scoreTuple2[1], scoreTuple1[1])
    )

proc loadHighScoreList*(fn: string): HighScoreList =
  var s = newFileStream(fn, fmRead)
  if (isNil(s)):
    result = newSeq[HighScoreTuple]()
  else:
    result = newSeq[HighScoreTuple]()
    while not s.atEnd:
      let element = newHighScore(s.readStr(3).string, s.readInt64.int)
      result.add(element)
    s.close()
    result.sortHighScoreList()

var highScoreList: HighScoreList = loadHighScoreList(DATA_FILE)


proc storeHighScoreList*(fn: string, data: HighScoreList) =
  var s = newFileStream(fn, fmWrite)
  for playerScore in data:
    s.write(playerScore[0])
    s.write(playerScore[1])
  s.close()

proc isTopTenScore*(rawPlayerScore: int): bool =

  if (len(highScoreList) == 0):
    result = true
  elif(highScoreList[len(highScoreList) - 1][1] < rawPlayerScore):
    result = true
  else:
    result = false

proc removeLowestHighScore(highScoreList: var HighScoreList) =
  let lastIndex: int = highScoreList.len - 1
  highScoreList.delete(lastIndex)

proc addHighScore*(playerHighScore: HighScoreTuple) =
  if(highScoreList[len(highScoreList) - 1][1] < playerHighScore[1]):
    echo "add new player score"
    if (len(highScoreList) >= 10):
      highScoreList.removeLowestHighScore()

    highScoreList.add(playerHighScore)

  highScoreList.sortHighScoreList()


when isMainModule:

  var dataLoaded = loadHighScoreList("./desktop/src/data_file.dat")

  let player0 = newHighScore("ABC", 123)
  let player1 = newHighScore("DEF", 99)
  let player2 = newHighScore("JAC", 2455)
  let player3 = newHighScore("WUT", 100)
  let player4 = newHighScore("HUH", 150)

  let player5 = newHighScore("YES", 110)
  let player6 = newHighScore("HGH", 115)

  var data: HighScoreList = @[player0,player1,player2,player3,player4]

  sortHighScoreList(data)

  storeHighScoreList("./desktop/src/data_file.dat", data)

  echo "data: ", repr(data)
  # echo "data len: ", data.len
  # for scoreTuple in data:
  #   echo "scoreTuple", repr(scoreTuple)
  # sort before storing
  # store("highscores.dat", data)
