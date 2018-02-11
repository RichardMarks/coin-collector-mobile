import sdl2, sdl2.ttf
import game_types
import scene_management

from text_renderer import TextObject, newTextObject, render, setText, setColor, setPivot, setScale, containsPoint, getWidth, getHeight
from game_input import wasClicked

type
  CreditsButton = enum none, back

  CreditsKind = enum headingType, normalType, separatorType
  CreditsEntry = tuple
    kind: CreditsKind
    text: string
    color: Color
    size: int

proc makeCreditsEntry(kind: CreditsKind, text: string = "", color: Color = WHITE, size: int = 0): CreditsEntry =
  result = (kind, text, color, size)

proc heading(text: string, color: Color = WHITE): CreditsEntry =
  result = makeCreditsEntry(CreditsKind.headingType, text, color)

proc normal(text: string, color: Color = WHITE): CreditsEntry =
  result = makeCreditsEntry(CreditsKind.normalType, text, color)

proc separator(size: int = 0): CreditsEntry =
  result = makeCreditsEntry(CreditsKind.separatorType, "", WHITE, size)

var
  activeButton: CreditsButton = CreditsButton.none
  backText: TextObject
  credits: seq[CreditsEntry] = @[
    heading("game design"),
    normal("Richard Marks"),
    normal("Stephen Collins"),
    separator(48),
    heading("programming"),
    normal("Richard Marks"),
    normal("Stephen Collins"),
    separator(48),
    heading("audio"),
    normal("Richard Marks")
  ]
  creditTexts: seq[TextObject] = @[]
  creditsTexture: TexturePtr
  creditsTextureDestination: Rect = rect(0, 0, 0, 0)
  headingFont: FontPtr
  normalFont: FontPtr
  firstRenderPass: bool = true

proc registerCreditsScene(scene: Scene, game: Game, tick: float) =
  # load assets here

  headingFont = openFont("../Kenteken.ttf", 30)
  sdlFailIf(headingFont.isNil): "Failed to load Kenteken.ttf"

  normalFont = openFont("../Imperator.ttf", 24)
  sdlFailIf(normalFont.isNil): "Failed to load Imperator.ttf"

  const CENTER_Y = SCREEN_H div 2

  backText = newTextObject(game.renderer, game.menuItemFont, WHITE)
  backText.setText("Back")
  backText.y = CENTER_Y + (3 * (CENTER_Y div 4))
  backText.x = SCREEN_W div 2
  backText.setPivot(0.5, 0.5)

  # we are going to center the credits display in the middle of the screen
  # each credits entry can have a different height, so a simple length calculation
  # will not work for our needs.

  # there are a few ways to approach the problem, but since there are so many
  # text objects and the text doesn't change, we can avoid a lot of excess
  # render calls.

  # we are going to render the credits once to a large texture
  # and then we will use that texture to render all the credits
  # to the screen centered with a single draw call

  # first we need to know the size of the texture
  var
    width: cint = 0
    height: cint = 0

  const CYAN = color(0x00, 0xCA, 0xCA, 0xFF)

  proc configureCreditsText(textObj: var TextObject, entry: CreditsEntry) =
    textObj.setText(entry.text)
    textObj.setPivot(0.5, 0)
    textObj.y = height
    let w: cint = textObj.getWidth()
    let h: cint = textObj.getHeight()
    if w > width:
      width = w
    height += h + 8
    creditTexts.add(textObj)

  for index, entry in credits:
    case entry.kind
    of CreditsKind.headingType:
      var textObj: TextObject = newTextObject(game.renderer, headingFont, CYAN)
      configureCreditsText(textObj, entry)
    of CreditsKind.normalType:
      var textObj: TextObject = newTextObject(game.renderer, normalFont, WHITE)
      configureCreditsText(textObj, entry)
    of CreditsKind.separatorType:
      height += entry.size.cint

  for textObj in creditTexts:
    textObj.x = width div 2

  creditsTextureDestination.w = width
  creditsTextureDestination.h = height

proc enterCreditsScene(scene: Scene, game: Game, tick: float) =
  # enter animation / show credits scene here
  firstRenderPass = true

proc updateCreditsScene(scene: Scene, game: Game, tick: float) =
  # called on game update proc
  let mx: cint = game.mouse.x.cint
  let my: cint = game.mouse.y.cint

  if backText.containsPoint(mx, my): activeButton = CreditsButton.back
  else: activeButton = CreditsButton.none

  if game.wasClicked():
    if activeButton == CreditsButton.back:
      game.sceneManager.enter("title")

proc renderButton(textObj: TextObject, matchActive: CreditsButton) =
  if matchActive == activeButton:
    textObj.setColor(YELLOW)
  else:
    textObj.setColor(WHITE)
  textObj.render()

proc renderCreditsTextToTexture(game: Game) =
  # create the texture that will hold the credits
  creditsTexture = game.renderer.createTexture(
    SDL_PIXELFORMAT_ABGR8888,
    SDL_TEXTUREACCESS_TARGET.cint,
    creditsTextureDestination.w,
    creditsTextureDestination.h)

  creditsTexture.setTextureBlendMode(BlendMode_Blend)

  # set the render target to our created texture
  game.renderer.setRenderTarget(creditsTexture)

  # clear the texture
  game.renderer.setDrawColor(r = 0x00, g = 0x00, b = 0x00, a = 0x00)
  game.renderer.clear()

  # loop over the credits text objects and render them to the texture (nothing special we already set the target)
  game.renderer.setDrawColor(r = 0x00, g = 0xFF, b = 0x00)
  for textObj in creditTexts:
    textObj.render()

  # reset the render target back to the screen so we'll be able to see other things we render :D
  game.renderer.setRenderTarget(nil)
  game.renderer.setDrawColor(r = 0x10, g = 0x10, b = 0x20)

  # calculate the position we need to render the credits texture
  # to center it on the screen
  creditsTextureDestination.x = (SCREEN_W - creditsTextureDestination.w) div 2
  creditsTextureDestination.y = (SCREEN_H - creditsTextureDestination.h) div 2

proc renderCreditsScene(scene: Scene, game: Game, tick: float) =
  if firstRenderPass:
    firstRenderPass = false
    renderCreditsTextToTexture(game)

  game.renderer.copy(creditsTexture, nil, addr creditsTextureDestination)

  backText.renderButton(CreditsButton.back)

proc exitCreditsScene(scene: Scene, game: Game, tick: float) =
  # exit animation / leave credits scene here
  creditsTexture.destroy()

proc destroyCreditsScene(scene: Scene, game: Game, tick: float) =
  # release assets here, like at game end

  normalFont.close()
  headingFont.close()

let creditsSlc* = [
  registerCreditsScene.SceneLifeCycleProc,
  enterCreditsScene.SceneLifeCycleProc,
  updateCreditsScene.SceneLifeCycleProc,
  renderCreditsScene.SceneLifeCycleProc,
  exitCreditsScene.SceneLifeCycleProc,
  destroyCreditsScene.SceneLifeCycleProc]
