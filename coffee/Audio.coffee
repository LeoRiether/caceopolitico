class Audio
  audio = {}
  getAudio: -> audio
  audioItv = undefined
  audioCtx = undefined
  getAudioCtx: -> audioCtx
  audioSource = undefined

  ajaxAudio: (url, key) =>
    ajax url, ((req) => audioCtx.decodeAudioData req.response, ((buff) => audio[key] = buff)), 'arraybuffer'

  constructor: ->
    try
      window.AudioContext = window.AudioContext||window.webkitAudioContext;
      audioCtx = new window.AudioContext();
      #ajaxAudio 'audio/Cunha/Cunha001.wav', 'beep'
      audioItv = setInterval @playSound, 100
    catch
      alert('Web Audio API não é suportado em seu browser');

  canPlaySound = yes
  setCanPlaySound = ->
    canPlaySound = yes
  playSound: ->
    return if not canPlaySound or not game.cacando
    audioSource = do audioCtx.createBufferSource
    if game.mdist < game.mouseRange[0]
      audioSource.buffer = audio[game.politico.audio[3]]
      setTimeout setCanPlaySound, 300
    else if game.mdist < game.mouseRange[1]
      audioSource.buffer = audio[game.politico.audio[2]]
      setTimeout setCanPlaySound, 350
    else if game.mdist < game.mouseRange[2]
      audioSource.buffer = audio[game.politico.audio[1]]
      setTimeout setCanPlaySound, 350
    else
      audioSource.buffer = audio[game.politico.audio[0]]
      setTimeout setCanPlaySound, 400
    canPlaySound = no
    #audioSource.buffer = audio[game.politico.audioKey];
    audioSource.connect audioCtx.destination
    audioSource.start 0

audio = new Audio()
