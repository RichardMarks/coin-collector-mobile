import basic2d
import strutils
import times
import math
import strfmt
import streams
import os

import sdl2
import sdl2.image
import sdl2.ttf

const SCREEN_W* = 1280
const SCREEN_H* = 720

const TILE_WIDTH* = 64
const TILE_HEIGHT* = 64
const TILE_THICKNESS* = 21

const BOARD_COLUMNS* = 10
const BOARD_ROWS* = 10
const BOARD_XLIMIT* = BOARD_COLUMNS - 1
const BOARD_YLIMIT* = BOARD_ROWS - 1
const BOARD_WIDTH* = TILE_WIDTH * BOARD_COLUMNS
const Y_SPACE* = TILE_HEIGHT - TILE_THICKNESS
const BOARD_HEIGHT* = Y_SPACE * BOARD_ROWS
const WHITE* = color(0xFF, 0xFF, 0xFF, 0xFF)
const YELLOW* = color(0xFF, 0xFF, 0x00, 0xFF)


const SCENE_LIFE_CYCLE_SIZE = 6

template sdlFailIf*(condition: typed, reason: string) =
  if condition:
    raise SDLException.newException(reason & ", SDL Error: " & $getError())

type
  SDLException* = object of Exception
  MissingSceneError* = object of Exception

  CacheLine* = object
    texture*: TexturePtr
    w*, h*: cint

  TextCache* = ref object
    text*: string
    cache*: array[2, CacheLine]

  Input* {.pure.} = enum
    none,
    click,
    up,
    down,
    left,
    right,
    cancel,
    confirm,
    quit,
    mouse

  MouseCoordinate* = tuple[x, y:int]

  SceneLifeCycleProc* = proc(scene: Scene, game: Game, tick: float)

  SceneLifeCycle* = array[SCENE_LIFE_CYCLE_SIZE, SceneLifeCycleProc]

  HighScoreTuple* = ref (string, int)

  HighScoreList* = seq[(HighScoreTuple)]

  GameState* = tuple
    board: string
    coins: int
    lives: int
    timer: int
    highScoresList: HighScoreList

  BoardEvent* = enum
    noop,
    foundDirt,
    foundCoin,
    foundPit,
    takeCoin

  Game* = ref object
    sceneManager*: GameSceneManager
    inputs*: array[Input, bool]
    inputPressed*: array[Input, bool]
    renderer*: RendererPtr
    font*: FontPtr
    menuItemFont*: FontPtr
    mouse*: MouseCoordinate
    state*: GameState

  GameSceneManager* = ref object
    current*: Scene
    registry*: seq[Scene]
    game*: Game

  Scene* = ref object
    name*: string
    index*: int
    onRegister*: SceneLifeCycleProc
    onEnter*: SceneLifeCycleProc
    onUpdate*: SceneLifeCycleProc
    onRender*: SceneLifeCycleProc
    onExit*: SceneLifeCycleProc
    onDestroy*: SceneLifeCycleProc

