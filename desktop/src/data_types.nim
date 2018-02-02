import sdl2, sdl2.image
import basic2d


type 
  SDLException* = object of Exception

  Input* {.pure.} = enum none, left, right, jump, restart, quit

  Player* = ref object
    texture: sdl2.TexturePtr
    pos: Point2d
    vel: Vector2d

  Game* = ref object
    inputs: array[Input, bool]
    renderer: sdl2.RendererPtr
    player: Player
    map: Map
    camera: Vector2d

  Map* = ref object
    texture: sdl2.TexturePtr
    width, height: int
    tiles: seq[uint8]