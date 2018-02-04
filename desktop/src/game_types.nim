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

type
  SDLException* = object of Exception

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

  Game* = ref object of RootObj
    sceneManager*: SceneManager
    inputs*: array[Input, bool]
    inputPressed*: array[Input, bool]
    renderer*: RendererPtr
    font*: FontPtr

  SceneManager* = ref object of RootObj
    currentScene*: Scene

  SceneObject* = ref object of RootObj
    tags*: seq[string]
    active*: bool
    visible*: bool
    x, y: float

  Scene* = ref object of RootObj
    name*: string
    manager*: SceneManager
    sceneObjects: seq[SceneObject]
    update*: SceneUpdateProcPtr
    render*: SceneRenderProcPtr
    enter*: SceneEnterProcPtr
    exit*: SceneExitProcPtr

  SceneUpdateProcPtr* = (proc(scene: Scene, game: Game, deltaTime: float))
  SceneRenderProcPtr* = (proc(scene: Scene, game: Game, deltaTime: float))
  SceneEnterProcPtr* = (proc(scene: Scene, game: Game))
  SceneExitProcPtr* = (proc(scene: Scene, game: Game))

