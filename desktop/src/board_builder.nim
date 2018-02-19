import times
import mersenne
from strutils import repeat, `%`
import os

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
  possibilities: string

const BOARD_COLUMNS* = 10
const BOARD_ROWS* = 10

type
  BoardData = array[BOARD_COLUMNS * BOARD_ROWS, char]


proc nextRandom*(low: uint32, high: uint32): uint32 =
  ## obtains a pseudo-random number R >= low < high
  result = uint32(low + (mt.getNum() mod (high - low)))

proc generateBoard(): BoardData =
  seed = epochTime().uint32
  mt = newMersenneTwister(seed)
  echo "seed = " & $seed
  coinChance = nextRandom(5, 30).int
  pitChance = nextRandom(10, 40).int
  dirtChance = 100 - (coinChance + pitChance)
  possibilities = COIN_TILE.repeat(coinChance) & PIT_TILE.repeat(pitChance) & DIRT_TILE.repeat(dirtChance)
  for y in 0..<BOARD_ROWS:
    for x in 0..<BOARD_COLUMNS:
      result[x + y * BOARD_COLUMNS] = possibilities[nextRandom(0, 100).int]

when isMainModule:
  var board: BoardData = generateBoard()
  echo "" & $coinChance & "% coins"
  echo "" & $pitChance & "% pits"
  echo "" & $dirtChance & "% dirt"
  sleep(1000)
  var board2: BoardData = generateBoard()
  echo "" & $coinChance & "% coins"
  echo "" & $pitChance & "% pits"
  echo "" & $dirtChance & "% dirt"

  for y in 0..<BOARD_ROWS:
    for x in 0..<BOARD_COLUMNS:
      stdout.write(board[x + y * BOARD_COLUMNS])
      stdout.write(' ')
    stdout.write("  ")
    for x in 0..<BOARD_COLUMNS:
      stdout.write(board2[x + y * BOARD_COLUMNS])
      stdout.write(' ')
    stdout.write(char(0xa))
  stdout.write(char(0xa))
