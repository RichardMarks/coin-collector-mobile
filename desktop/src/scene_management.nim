# import tables
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

proc newGameSceneManager*: GameSceneManager =
  ## GameSceneManager object constructor. Initializes new GameSceneManager.
  new result
  result.registry = newSeq[Scene](0)

proc register*(gsm: GameSceneManager, scene: Scene) =
  ## calls onRegister Scene Event
  gsm.registry.add(scene)
  var registeredSceneIndex: int = find(gsm.registry, scene)
  gsm.registry[registeredSceneIndex].onRegister()

proc enter*(gsm: GameSceneManager, scene: Scene) =
  ## calls onEnter Scene Event  

  var foundIndex: int = find(gsm.registry, scene)
  if foundIndex > -1:
    gsm.current = gsm.registry[foundIndex]
    gsm.current.onEnter()
  else:
    raise newException(MissingSceneError, "scene doesn't exist")

proc exit*(gsm: GameSceneManager, scene: Scene) =
  ## calls onExit Scene Event
  
  var foundIndex: int = find(gsm.registry, scene)
  if foundIndex > -1:
    gsm.registry[foundIndex].onExit()
  else:
    raise newException(MissingSceneError, "scene doesn't exist")

proc destroy*(gsm: GameSceneManager, scene: Scene) =
  ## calls onDestroy Scene Event
  
  var foundIndex: int = find(gsm.registry, scene)
  if foundIndex > -1:
    gsm.registry[foundIndex].onDestroy()
    gsm.registry.delete(foundIndex)


when isMainModule:

  # scene life cycle procedures

  # 1. called when a scene is registered
  proc registerTitleScene() =
    echo "registering title scene"

  proc registerPlayScene() =
      echo "registering play scene"

  # 2. called when the scene becomes the current scene
  proc enterTitleScene() =
    echo "entering title scene"

  proc enterPlayScene() =
    echo "entering play scene"

  # 3. called every update frame
  proc updateTitleScene() =
    echo "updating title scene"

  proc updatePlayScene() =
    echo "updating play scene"

  # 4. called every render frame
  proc renderTitleScene() =
    echo "rendering title scene"

  proc renderPlayScene() =
    echo "rendering play scene"

  # 5. called when the scene is no longer the current scene
  proc exitTitleScene() =
    echo "exiting title scene"

  proc exitPlayScene() =
    echo "exiting play scene"

  # 6. called when the program exits
  proc destroyTitleScene() =
    echo "destroying title scene"

  proc destroyPlayScene() =
    echo "destroying play scene"
  let titleScene* = newScene(
    "title",
    newSeq[SceneObject](0),
    [registerTitleScene.SceneLifeCycleProc,
    enterTitleScene.SceneLifeCycleProc,
    updateTitleScene.SceneLifeCycleProc,
    renderTitleScene.SceneLifeCycleProc,
    exitTitleScene.SceneLifeCycleProc,
    destroyTitleScene.SceneLifeCycleProc]
  )

  let playScene* = newScene(
    "play",
    newSeq[SceneObject](0),
    [registerPlayScene.SceneLifeCycleProc,
    enterPlayScene.SceneLifeCycleProc,
    updatePlayScene.SceneLifeCycleProc,
    renderPlayScene.SceneLifeCycleProc,
    exitPlayScene.SceneLifeCycleProc,
    destroyPlayScene.SceneLifeCycleProc]
  )

  let gsm = newGameSceneManager()

  gsm.register(titleScene)
  gsm.register(playScene)
  gsm.enter(titleScene)
  echo "press enter to play"
  discard stdin.readLine()
  gsm.exit(titleScene)
  gsm.enter(playScene)
  echo "press enter to go back to title"
  discard stdin.readLine()
  gsm.exit(playScene)
  gsm.enter(titleScene)
  echo "press enter to quit"
  discard stdin.readLine()
  gsm.exit(titleScene)
  gsm.destroy(playScene)
  gsm.destroy(titleScene)
