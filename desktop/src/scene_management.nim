import game_types

proc newScene*(name: string, slc: SceneLifeCycle): Scene =
  ## Scene object constructor. Initializes new Scene.

  new result
  result.name = name
  result.onRegister = slc[0]
  result.onEnter = slc[1]
  result.onUpdate = slc[2]
  result.onRender = slc[3]
  result.onExit = slc[4]
  result.onDestroy = slc[5]

proc newGameSceneManager*(game: Game): GameSceneManager =
  ## GameSceneManager object constructor. Initializes new GameSceneManager.
  new result
  result.game = game
  result.registry = newSeq[Scene](0)

proc register*(gsm: GameSceneManager, scene: Scene) =
  ## calls onRegister Scene Event
  gsm.registry.add(scene)
  scene.onRegister(scene, gsm.game, 0)

proc findScene(gsm: GameSceneManager, sceneName: string): Scene =
  ## finds a Scene in the scene registry by name and returns a reference to the Scene
  ## raises MissingSceneError if there is no scene with the name given
  var foundIndex: int = -1
  for i in gsm.registry.low..gsm.registry.high:
    var scene = gsm.registry[i]
    if scene.name == sceneName:
      foundIndex = i
  if foundIndex > -1:
    gsm.registry[foundIndex].index = foundIndex
    result = gsm.registry[foundIndex]
  else:
    raise newException(MissingSceneError, "scene doesn't exist")

proc enter*(gsm: GameSceneManager, sceneName: string) =
  ## calls onEnter Scene Event

  let scene = gsm.findScene(sceneName)
  # if the current scene is not the new scene
  if gsm.current != scene:
    # if there is a current scene, exit it first
    if gsm.current != nil:
      gsm.current.onExit(gsm.current, gsm.game, 0)
    # change the scene
    gsm.current = scene
    scene.onEnter(scene, gsm.game, 0)

proc exit*(gsm: GameSceneManager, sceneName: string) =
  ## calls onExit Scene Event

  let scene = gsm.findScene(sceneName)
  scene.onExit(scene, gsm.game, 0)
  gsm.current = nil

proc destroy*(gsm: GameSceneManager, sceneName: string) =
  ## calls onDestroy Scene Event

  let scene = gsm.findScene(sceneName)
  if scene == gsm.current:
    scene.onExit(scene, gsm.game, 0)
  scene.onDestroy(scene, gsm.game, 0)
  gsm.registry.delete(scene.index)
