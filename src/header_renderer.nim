from strutils import `%`
include game_data

proc renderHeader*(game:GameData) =
  ## renders header for game
  echo """
  S - Stone                Lives Remaining: $1
  D - Dirt                 Coins Collected: $2
  P - Pit
  C - Coin """ % [$game.lives, $game.coins]
