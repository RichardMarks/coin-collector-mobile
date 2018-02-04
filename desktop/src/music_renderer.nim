import sdl2/mixer

proc startBGM*(): MusicPtr =
  var
    audio_buffers: cint = 4096
    audio_channels: cint = 2
    bgm: MusicPtr
    channel: cint
    audio_rate: cint
    audio_format: uint16

  if mixer.openAudio(audio_rate, audio_format, audio_channels, audio_buffers) != 0:
    quit("There was a problem")
  
  bgm = mixer.loadMUS("../audio_files/bgm.ogg")
  if isNil(bgm):
    quit("Unable to load sound file")
  
  channel = mixer.playMusic(bgm, -1); #ogg/flac
  if channel == -1:
    quit("Unable to play sound")


proc stopBGM*(bgm: MusicPtr): int =
  mixer.freeMusic(bgm) #clear ogg
  mixer.closeAudio()