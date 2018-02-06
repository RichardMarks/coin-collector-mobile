import game_types

proc newScene*(name: string, slc: SceneLifeCycle): Scene =
  ## Scene object constructor. Initializes new Scene.

  new result
  result.name = name
  result.sceneObjects = @[]
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
  gsm.current = scene
  scene.onEnter(scene, gsm.game, 0)

proc exit*(gsm: GameSceneManager, sceneName: string) =
  ## calls onExit Scene Event

  let scene = gsm.findScene(sceneName)
  scene.onExit(scene, gsm.game, 0)

proc destroy*(gsm: GameSceneManager, sceneName: string) =
  ## calls onDestroy Scene Event

  let scene = gsm.findScene(sceneName)
  scene.onDestroy(scene, gsm.game, 0)
  gsm.registry.delete(scene.index)


# when isMainModule:

#   # scene life cycle procedures

#   # 1. called when a scene is registered
#   proc registerTitleScene(scene: Scene, game: Game, tick:int) =
#     echo "registering title scene"

#   proc registerPlayScene(scene: Scene, game: Game, tick:int) =
#       echo "registering play scene"

#   # 2. called when the scene becomes the current scene
#   proc enterTitleScene(scene: Scene, game: Game, tick:int) =
#     echo "entering title scene"

#   proc enterPlayScene(scene: Scene, game: Game, tick:int) =
#     echo "entering play scene"

#   # 3. called every update frame
#   proc updateTitleScene(scene: Scene, game: Game, tick:int) =
#     echo "updating title scene"

#   proc updatePlayScene(scene: Scene, game: Game, tick:int) =
#     echo "updating play scene"

#   # 4. called every render frame
#   proc renderTitleScene(scene: Scene, game: Game, tick:int) =
#     echo "rendering title scene"

#   proc renderPlayScene(scene: Scene, game: Game, tick:int) =
#     echo "rendering play scene"

#   # 5. called when the scene is no longer the current scene
#   proc exitTitleScene(scene: Scene, game: Game, tick:int) =
#     echo "exiting title scene"

#   proc exitPlayScene(scene: Scene, game: Game, tick:int) =
#     echo "exiting play scene"

#   # 6. called when the program exits
#   proc destroyTitleScene(scene: Scene, game: Game, tick:int) =
#     echo "destroying title scene"

#   proc destroyPlayScene(scene: Scene, game: Game, tick:int) =
#     echo "destroying play scene"
#   let titleScene* = newScene(
#     "title",
#     [registerTitleScene.SceneLifeCycleProc,
#     enterTitleScene.SceneLifeCycleProc,
#     updateTitleScene.SceneLifeCycleProc,
#     renderTitleScene.SceneLifeCycleProc,
#     exitTitleScene.SceneLifeCycleProc,
#     destroyTitleScene.SceneLifeCycleProc]
#   )

#   let playScene* = newScene(
#     "play",
#     [registerPlayScene.SceneLifeCycleProc,
#     enterPlayScene.SceneLifeCycleProc,
#     updatePlayScene.SceneLifeCycleProc,
#     renderPlayScene.SceneLifeCycleProc,
#     exitPlayScene.SceneLifeCycleProc,
#     destroyPlayScene.SceneLifeCycleProc]
#   )

#   let gsm = newGameSceneManager()

#   gsm.register(titleScene)
#   gsm.register(playScene)
#   gsm.enter("title")
#   echo "press enter to play"
#   discard stdin.readLine()
#   gsm.exit("title")
#   gsm.enter("play")
#   echo "press enter to go back to title"
#   discard stdin.readLine()
#   gsm.exit("play")
#   gsm.enter("title")
#   echo "press enter to quit"
#   discard stdin.readLine()
#   gsm.exit("title")
#   gsm.destroy("play")
#   gsm.destroy("title")
