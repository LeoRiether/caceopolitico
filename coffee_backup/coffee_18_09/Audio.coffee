class Audio
  audio = {}
  getAudio: -> audio
  audioItv = undefined
  audioCtx = undefined
  getAudioCtx: -> audioCtx
  audioSource = undefined
  ajaxAudio = (url, key) ->
    ajax url, ((req) -> audioCtx.decodeAudioData req.response, ((buff) -> audio[key] = buff)), 'arraybuffer'

  constructor: ->
    try
      window.AudioContext = window.AudioContext||window.webkitAudioContext;
      audioCtx = new window.AudioContext();
      ajaxAudio 'audio/beep.mp3', 'beep'
      audioItv = setInterval @playSound, 100
    catch
      alert('Web Audio API não é suportado em seu browser');

  canPlaySound = yes
  setCanPlaySound = ->
    canPlaySound = yes
  playSound: ->
    return if not canPlaySound or not game.cacando
    if game.mdist < game.mouseRange[0]
      setTimeout setCanPlaySound, 150
    else if game.mdist < game.mouseRange[1]
      setTimeout setCanPlaySound, 300
    else if game.mdist < game.mouseRange[2]
      setTimeout setCanPlaySound, 500
    else
      setTimeout setCanPlaySound, 800
    canPlaySound = no
    audioSource = do audioCtx.createBufferSource
    audioSource.buffer = audio[game.politico.audioKey];
    audioSource.connect audioCtx.destination
    audioSource.start 0

audio = new Audio()
