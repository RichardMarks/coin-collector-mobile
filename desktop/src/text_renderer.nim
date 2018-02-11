import game_types
import sdl2, sdl2.ttf

type
  TextRenderProperties = tuple
    ## string of text that will be rendered
    text: string
    ## color of the rendered text
    color: Color

  TextPivot = tuple
    ## in range 0.0 (left) to 1.0 (right)
    x: float
    ## in range 0.0 (top) to 1.0 (bottom)
    y: float

  TextScale = tuple
    ## multiplied by width to scale on X axis 1.0 = 100% 2.0 = 200%
    x: float
    ## multiplied by height to scale on Y axis 1.0 = 100% 2.0 = 200%
    y: float

  TextProperties = tuple
    ## text will rendered with this font
    font: FontPtr
    ## text is rendered to this texture when textproperties change, and the texture is copied to the renderer
    texture: TexturePtr
    ## width of the rendered string of text in pixels
    width: cint
    ## height of the rendered string of text in pixels
    height: cint
    ## text will be rendered offset by -x*width and -y*height pivot
    pivot: TextPivot
    ## text scale factor
    scale: TextScale
    ## the source rectangle of the texture data copy
    src: Rect
    ## used to hold the rendering pivot value
    pvt: Rect
    ## the destination rectangle of the texture data copy
    dst: Rect

  TextObject* = ref object of RootObj
    ## a reference to the renderer that will be doing all the...rendering
    renderer*: RendererPtr
    ## private properties that affect rendering results but do not cause a new rendering of the text texture
    properties: TextProperties
    ## private properties that will cause re-rendering when changed
    renderProperties: TextRenderProperties
    ## horizontal position of the text relative to the pivot point
    x*: cint
    ## vertical position of the text relative to the pivot point
    y*: cint

# API v1.0
# var text:TextObject = newTextObject(renderer, font, color)
# text.setText("Hello, World")
# text.setColor(0xFF, 0xFF, 0xFF, 0xFF)
# text.setPivot(0.5, 0.5)
# text.render()
# var t: string = text.getText()
# var c: tuple[r, g, b, a: uint8] = text.getColor()
# var w: int text.getWidth()
# var h: int text.getHeight()
# var tuple[x, y: float] = text.getPivot()

# var text:TextObject = newTextObject(renderer, font, color)
proc newTextObject*(renderer: RendererPtr, font: FontPtr, color: Color): TextObject =
  ## constructs a new TextObject on the heap
  ## maintains a reference to the renderer and font and copies the color into internal render properties
  new result
  # set the references
  result.renderer = renderer
  result.properties.font = font

  # set the initial color
  result.renderProperties.color = color

  # read from the top left of the texture
  result.properties.src.x = 0
  result.properties.src.y = 0

  # by default render at the top left corner of the screen
  result.x = 0
  result.y = 0

  # initial scale is 100% on both x and y axes
  result.properties.scale.x = 1.0
  result.properties.scale.y = 1.0

proc privateUpdatePivot(textObj: TextObject) =
  ## used internally by TextObject procedure
  ## privateRenderText and setPivot
  ## to update the pivot cache data

  textObj.properties.pvt.w = textObj.properties.width
  textObj.properties.pvt.h = textObj.properties.height

  var
    textWidth: float = textObj.properties.width.float * textObj.properties.scale.x
    textHeight: float = textObj.properties.height.float * textObj.properties.scale.y

  textObj.properties.pvt.x = cint(textObj.properties.pivot.x * -textWidth)
  textObj.properties.pvt.y = cint(textObj.properties.pivot.y * -textHeight)

  textObj.properties.dst.w = textWidth.cint
  textObj.properties.dst.h = textHeight.cint

proc privateRenderText(textObj: TextObject) =
  ## used internally by TextObject procedures
  ## setText and setColor
  ## to destroy and re-render the text

  let font = textObj.properties.font
  let text: cstring = textObj.renderProperties.text.cstring
  let color: Color = textObj.renderProperties.color

  # render the text to a new temporary surface
  var temporarySurface: SurfacePtr = font.renderUtf8Blended(text, color)

  # set the source alpha modulation for the surface to texture render pass
  discard temporarySurface.setSurfaceAlphaMod(color.a)

  # update the rendered text size information
  textObj.properties.width = temporarySurface.w
  textObj.properties.height = temporarySurface.h
  textObj.properties.src.w = temporarySurface.w
  textObj.properties.src.h = temporarySurface.h

  # update the cached texture with the pixel data from the temporary surface
  textObj.properties.texture = textObj.renderer.createTextureFromSurface(temporarySurface)

  # release the allocated memory for the temporary surface
  temporarySurface.freeSurface()

  # update the rendering pivot information if the width or height of the texture changed
  if textObj.properties.pvt.w != textObj.properties.width or
     textObj.properties.pvt.h != textObj.properties.height:
    privateUpdatePivot(textObj)

proc privateReleaseCachedTexture(textObj: TextObject) =
  ## used internally by TextObject procedures
  ## setText and setColor
  ## to destroy the cached texture if it is not nil
  if not textObj.properties.texture.isNil:
    textObj.properties.texture.destroy()

# text.setText("Hello, World")
proc setText*(textObj: TextObject, text: string) =
  ## updates the cached texture with new string of rendered text
  ## will re-render the cached texture if the given text differs from the cached text value

  if text != textObj.renderProperties.text:
    privateReleaseCachedTexture(textObj)
    textObj.renderProperties.text = text
    privateRenderText(textObj)

# text.setColor(0xFF, 0xFF, 0xFF, 0xFF)
proc setColor*(textObj: TextObject, r: uint8, g: uint8, b: uint8, a: uint8) =
  ## updates the cached texture with text rendered in new color
  ## will re-render the cached texture if the given color differs from the cached color value

  let currentColor: Color = textObj.renderProperties.color

  if r != currentColor.r or g != currentColor.g or b != currentColor.b or a != currentColor.a:
    privateReleaseCachedTexture(textObj)
    textObj.renderProperties.color = color(r, g, b, a)
    privateRenderText(textObj)

# text.setColor(color(0xFF, 0xFF, 0xFF, 0xFF))
proc setColor*(textObj: TextObject, color: Color) =
  ## updates the cached texture with text rendered in new color
  ## will re-render the cached texture if the given color differs from the cached color value
  textObj.setColor(color.r, color.g, color.b, color.a)

# text.setPivot(0.5, 0.5)
proc setPivot*(textObj: TextObject, x: float = 0.5, y: float = 0.5) =
  ## updates the pivot point used to determine the rendering offset
  ## when rendering text to the screen using textObj.render()

  if int(x * 10) != int(textObj.properties.pivot.x * 10) or
     int(y * 10) != int(textObj.properties.pivot.y * 10):
    textObj.properties.pivot.x = x
    textObj.properties.pivot.y = y
    privateUpdatePivot(textObj)

proc setScale*(textObj: TextObject, x: float = 1.0, y: float = 1.0) =
  ## updates the scale factor used to determine the size of the rendered text

  if int(x * 10) != int(textObj.properties.scale.x * 10) or
     int(y * 10) != int(textObj.properties.scale.y * 10):
    textObj.properties.scale.x = x
    textObj.properties.scale.y = y
    privateUpdatePivot(textObj)

# text.render()
proc render*(textObj: TextObject) =
  ## renders the text object's cached texture to the current rendering target via renderer.copy
  ## if there is no texture cached, nothing will be rendered

  let texture: TexturePtr = textObj.properties.texture
  if not texture.isNil:
    let src: ptr Rect = addr textObj.properties.src
    let pvt: ptr Rect = addr textObj.properties.pvt
    let dst: ptr Rect = addr textObj.properties.dst

    # offset using the cached pivot point
    dst.x = textObj.x + pvt.x
    dst.y = textObj.y + pvt.y

    # copy the pixels from the texture to the current rendering target
    copy(textObj.renderer, texture, src, dst)

    # echo "render " & textObj.renderProperties.text & ": ", repr(texture), repr(src), repr(dst)

proc containsPoint*(textObj: TextObject, x, y: cint): bool =
  ## returns true when the given 2d point is within the bounds of the rendered text
  ## uses the internal blitting destination rectangle to take into account scaling and pivot
  let dst: ptr Rect = addr textObj.properties.dst
  result = false
  if x >= dst.x and x <= dst.x + dst.w and y >= dst.y and y <= dst.y + dst.h:
    result = true

proc getWidth*(textObj: TextObject):cint =
  result = textObj.properties.dst.w

proc getHeight*(textObj: TextObject):cint =
  result = textObj.properties.dst.h

proc newTextCache*(): TextCache =
  new result

proc renderText*(renderer: RendererPtr, font: FontPtr, text: string, x, y, outline: cint, color: Color): CacheLine =
  font.setFontOutline(outline)
  let surface = font.renderUtf8Blended(text.cstring, color)
  sdlFailIf(surface.isNil):
    "Failed to render text surface: " & text
  discard surface.setSurfaceAlphaMod(color.a)

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

template renderTextCached*(game: Game, text: string, x, y: cint, color: Color) =
  block:
    var tc {.global.} = newTextCache()
    game.renderText(text, x, y, color, tc)
