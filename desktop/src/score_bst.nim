when isMainModule:
  var scores: array[10, int] = [1000, 500, 400, 200, 100, 50, 20, 10, 5, 1]
  echo $scores[0..<10]
  var score: int = 250
  var pos: int = 0
  while pos < 10:
    if scores[pos] < score:
      echo "position to insert is " & $pos
      for i in 0..<(9 - pos):
        var dst: int = 9 - i
        var src: int = 9 - (i + 1)
        echo "shift from " & $src & " to " & $dst
        scores[dst] = scores[src]
      scores[pos] = score
      break
    pos += 1
  echo $scores[0..<10]
