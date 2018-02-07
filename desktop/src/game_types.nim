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

  SceneLifeCycleProc* = proc(scene: Scene, game: Game, tick:int)

  SceneLifeCycle* = array[SCENE_LIFE_CYCLE_SIZE, SceneLifeCycleProc]

  Game* = ref object
    sceneManager*: GameSceneManager
    inputs*: array[Input, bool]
    inputPressed*: array[Input, bool]
    renderer*: RendererPtr
    font*: FontPtr
    mouse*: MouseCoordinate

  GameSceneManager* = ref object
    current*: Scene
    registry*: seq[Scene]
    game*: Game

  SceneObject* = ref object
    tags*: seq[string]
    active*: bool
    visible*: bool
    x*, y*: float

  Scene* = ref object
    name*: string
    index*: int
    sceneObjects*: seq[SceneObject]
    onRegister*: SceneLifeCycleProc
    onEnter*: SceneLifeCycleProc
    onUpdate*: SceneLifeCycleProc
    onRender*: SceneLifeCycleProc
    onExit*: SceneLifeCycleProc
    onDestroy*: SceneLifeCycleProc

