import sdl2/mixer

type
  BackgroundMusic = ref object
    music: MusicPtr
    channel: cint
    stopped: bool

proc newBackgroundMusic(): BackgroundMusic =
  new result
  result.stopped = false
  result.music = nil

var bgm: BackgroundMusic = newBackgroundMusic()
const BYTES_USED_PER_OUTPUT_SAMPLE = 4096
const AUDIO_CHANNELS = 2 # stereo
const AUDIO_FORMAT = MIX_DEFAULT_FORMAT
const FREQUENCY = MIX_DEFAULT_FREQUENCY
const LOOPING_PLAYBACK = -1 # 0 for single play

proc startBGM*() =
  if mixer.openAudio(FREQUENCY, AUDIO_FORMAT, AUDIO_CHANNELS, BYTES_USED_PER_OUTPUT_SAMPLE) != 0:
    quit("Failed to open audio")

  bgm.music = mixer.loadMUS("../audio_files/bgm.ogg")

  if isNil(bgm.music):
    quit("Unable to load bgm file")

  bgm.channel = mixer.playMusic(bgm.music, LOOPING_PLAYBACK);
  if bgm.channel < 0:
    quit("Unable to play bgm")

proc stopBGM*() =
  if bgm.stopped:
    return
  mixer.freeMusic(bgm.music)
  mixer.closeAudio()
  bgm.stopped = true
  bgm.music = nil
