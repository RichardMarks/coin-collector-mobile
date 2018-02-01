from strutils import startsWith, toLowerAscii
from game_loop import runGameLoop

proc runMainLoop*() =
  ## runs the main loop of the game which
  ## simply kicks off a game session and
  ## asks to play again when the game session ends
  while true:
    runGameLoop()
    echo "*** G A M E  O V E R ***"
    echo "Play Again? (Y/N) "
    if stdin.readLine().toLowerAscii.startsWith("n"):
      break

when isMainModule:
  runMainLoop()
