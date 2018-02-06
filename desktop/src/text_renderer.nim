import game_types
import sdl2, sdl2.ttf


proc newTextCache*(): TextCache =
  new result

proc renderText*(renderer: RendererPtr, font: FontPtr, text: string, x, y, outline: cint, color: Color): CacheLine =
  font.setFontOutline(outline)
  let surface = font.renderUtf8Blended(text.cstring, color)
  sdlFailIf(surface.isNil):
    "Failed to render text surface: " & text
  discard surface.setSurfaceAlphaMod(color.a)

template renderTextCached*(game: Game, text: string, x, y: cint, color: Color) =
  block:
    var tc {.global.} = newTextCache()
    game.renderText(text, x, y, color, tc)

  result.w = surface.w
  result.h = surface.h
  result.texture = renderer.createTextureFromSurface(surface)

  sdlFailIf(result.texture.isNil):
    "Failed to create texture from rendered text: " & text

  surface.freeSurface()

proc renderText*(game: Game, text: string, x, y: cint, color: Color, tc: TextCache) =
  let passes = [
    (color: color(0, 0, 0, 64), outline: 2.cint),
    (color: color, outline: 0.cint)
  ]

  if text != tc.text:
    for i in 0..1:
      tc.cache[i].texture.destroy()
      tc.cache[i] = game.renderer.renderText(game.font, text, x, y, passes[i].outline, passes[i].color)
      tc.text = text
  for i in 0..1:
    var
      source = rect(0, 0, tc.cache[i].w, tc.cache[i].h)
      dest = rect(x - passes[i].outline, y - passes[i].outline, tc.cache[i].w, tc.cache[i].h)
    game.renderer.copyEx(tc.cache[i].texture, source, dest, angle = 0.0, center = nil, flip = SDL_FLIP_NONE)
