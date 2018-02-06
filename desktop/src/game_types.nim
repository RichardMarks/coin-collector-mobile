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

type
  SDLException* = object of Exception
  MissingSceneError* = object of Exception

  CacheLine* = object
    texture: TexturePtr
    w, h: cint
  
  TextCache* = ref object
    text: string
    cache: array[2, CacheLine]
  
  Input {.pure.} = enum
    none,
    click,
    up,
    down,
    left,
    right,
    cancel,
    confirm,
    quit
  
  SceneLifeCycleProc* = proc()

  SceneLifeCycle* = array[SCENE_LIFE_CYCLE_SIZE, SceneLifeCycleProc]
  
  Game* = ref object
    sceneManager*: GameSceneManager
    inputs*: array[Input, bool]
    inputPressed*: array[Input, bool]
    renderer*: RendererPtr
    font*: FontPtr

  GameSceneManager* = ref object
    current: Scene
    registry: seq[Scene]

  SceneObject* = ref object
    tags*: seq[string]
    active*: bool
    visible*: bool
    x, y: float

  Scene* = ref object
    name*: string
    sceneObjects*: seq[SceneObject]
    onRegister: SceneLifeCycleProc
    onEnter: SceneLifeCycleProc
    onUpdate: SceneLifeCycleProc
    onRender: SceneLifeCycleProc
    onExit: SceneLifeCycleProc
    onDestroy: SceneLifeCycleProc

