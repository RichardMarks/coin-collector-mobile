import sdl2, sdl2.image, sdl2.ttf
import basic2d


type 
  SDLException* = object of Exception

  Input* {.pure.} = enum none, left, right, jump, restart, quit

  CacheLine* = object
    texture: TexturePtr
    w, h: cint

  TextCache* = ref object
    text: string
    cache: array[2, CacheLine]

  Time* = ref object
    begin, finish, best: int

  Player* = ref object
    texture: sdl2.TexturePtr
    pos: Point2d
    vel: Vector2d
    time: Time

  Game* = ref object
    inputs: array[Input, bool]
    renderer: sdl2.RendererPtr
    player: Player
    map: Map
    camera: Vector2d
    font: FontPtr

  Map* = ref object
    texture: sdl2.TexturePtr
    width, height: int
    tiles: seq[uint8]

  Collision* {.pure.} = enum x, y, corner