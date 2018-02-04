import tables

# include game_types

const SCENE_LIFE_CYCLE_SIZE = 6
type SceneLifeCycleProc = proc()
type
  Scene = ref object
    name: string
    onRegister: SceneLifeCycleProc
    onEnter: SceneLifeCycleProc
    onUpdate: SceneLifeCycleProc
    onRender: SceneLifeCycleProc
    onExit: SceneLifeCycleProc
    onDestroy: SceneLifeCycleProc

  GameSceneManager = ref object
    current: Scene
    # registry: seq[Scene]

  SceneLifeCycle = array[SCENE_LIFE_CYCLE_SIZE, SceneLifeCycleProc]

proc newScene(name: string, slc:SceneLifeCycle): Scene =
  new result
  result.name = name
  result.onRegister = slc[0]
  result.onEnter = slc[1]
  result.onUpdate = slc[2]
  result.onRender = slc[3]
  result.onExit = slc[4]
  result.onDestroy = slc[5]

proc newGameSceneManager: GameSceneManager =
  new result
  # result.registry

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

when isMainModule:
  let titleScene* = newScene(
    name = "title",
    slc = [registerTitleScene,
    enterTitleScene,
    updateTitleScene,
    renderTitleScene,
    exitTitleScene,
    destroyTitleScene]
  )

  let playScene* = newScene(
    "play",
    [registerPlayScene,
    enterPlayScene,
    updatePlayScene,
    renderPlayScene,
    exitPlayScene,
    destroyPlayScene]
  )

  let gsm = newGameSceneManager()

  gsm.register(titleScene)
  gsm.register(playScene)
  gsm.enter("title")
  echo "press enter to play"
  discard stdin.readLine()
  gsm.exit("title")
  gsm.enter("play")
  echo "press enter to go back to title"
  discard stdin.readLine()
  gsm.exit("play")
  gsm.enter("title")
  echo "press enter to quit"
  discard stdin.readLine()
  gsm.exit("title")
  gsm.destroy("play")
  gsm.destroy("title")
