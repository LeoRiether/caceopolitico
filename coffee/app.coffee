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



ajax = (url, fn, respType) ->
  req = new XMLHttpRequest()
  req.open 'GET', url, yes
  req.responseType = respType if respType?
  req.onload = fn.bind null, req if fn?
  do req.send

class Politico
  constructor: (@name, @unblock, img, @audioKey) ->
    @img = "img/#{img}.png"
    #@audio = ("audio/#{audioKey}/#{audioKey}00#{i}.wav" for i in [1..4])
    @audio = (for i in [1..4]
      k = "#{@audioKey}00#{i}"
      l = "audio/#{@audioKey}/#{k}.wav"
      audio.ajaxAudio l, k
      k
    )
  blocked: yes

class Storage
  constructor: ->
    pontos = parseInt(localStorage.pontos) || localStorage.pontos = 0
    Object.defineProperty @, 'pontos', {
      get: => pontos
      set: (v) => localStorage.pontos = pontos = v
      configurable: no
    }
  addPontos: (a = 1) ->
    @pontos += a


storage = new Storage()

class Modal
  triggerAfterAnim: =>
    do @setPontos
    do @show
    do game.removePoliticoImg

  hide: ->
    dom.modal.classList.add 'hidden'
  show: ->
    dom.modal.classList.remove 'hidden'
  toggle: ->
    dom.modal.classList.toggle 'hidden'

  startHide: ->
    dom.startModal.classList.add 'hidden'
  startShow: ->
    dom.startModal.classList.remove 'hidden'
  startToggle: ->
    dom.startModal.classList.toggle 'hidden'

  setPontos: ->
    dom.modalPontos.innerHTML = storage.pontos

  startBtnClick: =>
    game.cacando = yes
    @startHide()
    do game.makePolitico

  repeatBtnClick: ->
    return if game.cacando
    setTimeout (-> game.cacando = yes), 800
    do game.removePoliticoImg
    do game.makePolitico
    do modal.hide

  switchBtnClick: =>
    do @hide
    do @startShow

modal = new Modal()

class Game
  #mouseRange: [ 100, 500, 1000, 2000 ]
  screenWidth = Math.max(Math.max(document.documentElement.clientWidth, window.innerWidth || 0), Math.max(document.documentElement.clientHeight, window.innerWidth || 0))
  mouseRange: [ 0.0528033, 0.26, 0.520833, 0.7 ].map (e) -> e*screenWidth
  mdist: Game::mouseRange[1]
  politico: {}
  politicoIdx: 0
  cacando: no
  politicos = [
    new Politico 'Temer', 0, 'temer', 'Temer'
    new Politico 'Dilma', 5, 'Dilma', 'Dilma'
    new Politico 'Cunha', 10, 'Cunha', 'Cunha'
  ]
  bodyMouseMove: ({ clientX: x, clientY: y }) =>
    return if not @cacando
    @mdist = dist(x, y, @politico.x, @politico.y)
    if @mdist < @mouseRange[0]
      dom.body.style.cursor = 'pointer'
    else
      dom.body.style.cursor = ''

  bodyTouchMove: ({ touches: [ a ] }) =>
    @bodyMouseMove a

  dist = (x0, y0, x1, y1) ->
    dx = x1 - x0
    dy = y1 - y0
    Math.sqrt dx*dx + dy*dy

  bodyClick: =>
    return if not @cacando
    if @mdist < @mouseRange[0]
      dom.body.style.removeProperty 'background'
      dom.body.style.removeProperty 'cursor'
      do @makePoliticoImg
      storage.addPontos()
      setTimeout modal.triggerAfterAnim, 1000
      @cacando = no
      @mdist = @mouseRange[1]

  makePolitico: ->
    w = do dom.getWidth
    h = do dom.getHeight
    @politico = politicos[@politicoIdx]
    @politico.x = Math.floor Math.random() * (w-0.05*w) + 0.025*w
    @politico.y = Math.floor Math.random() * (h-0.05*h) + 0.025*h
    a = document.querySelector('.hint')
    a.style.top = @politico.y + 'px'
    a.style.left = @politico.x + 'px'

  makePoliticoImg: ->
    img = document.createElement 'img'
    img.setAttribute 'src', @politico.img
    img.classList.add 'polImg'
    img.style.left = "#{@politico.x}px"
    img.style.top = "#{@politico.y}px"
    dom.body.appendChild img
    dom.polImgModal.setAttribute 'src', @politico.img

  removePoliticoImg: ->
    polImg = document.querySelector('.polImg')
    do polImg.remove if polImg

game = new Game()

class Dom
  constructor: ->
    @body = document.body
    @modal = document.querySelector '.modal'
    @modalPontos = @modal.querySelector '.pontos'
    @repeatBtn = @modal.querySelector '.repeat'
    @switchBtn = @modal.querySelector '.switch'
    @polImgModal = @modal.querySelector '.polImgModal'
    @startModal = document.querySelector '.start-modal'
    @polListStart = @startModal.querySelectorAll '.pol-list li'
    @startBtn = @startModal.querySelector '.btn'
    @infoBtn = document.querySelector '.info-btn'
    @infoWindow = document.querySelector '.info-window'
    @closeInfo = @infoWindow.querySelector '.close'

    @bindEvents()

  ael = (d, e, l) ->
    d.addEventListener e, l

  throttle = (f, d) ->
    t = no
    ->
      return if t
      t = yes
      setTimeout (-> t = no), d
      f arguments...

  bindEvents: ->
    ael document, 'mousemove', throttle game.bodyMouseMove, 80
    ael document, 'touchmove', throttle game.bodyTouchMove, 80
    ael @body, 'click', game.bodyClick
    ael @repeatBtn, 'click', modal.repeatBtnClick
    ael @switchBtn, 'click', modal.switchBtnClick
    ael @startBtn, 'click', modal.startBtnClick
    @polListStart.forEach ((li) =>
      ael li, 'click', ((e) =>
        game.politicoIdx = parseInt e.target.dataset.pol
        @startModal.querySelector('.active').classList.remove 'active'
        li.classList.add 'active'
      )
    )
    paused = no
    ael @infoBtn, 'click', (=> @infoWindow.classList.toggle 'hidden'; game.cacando = [paused, paused = game.cacando][0])
    ael @closeInfo, 'click', (=> @infoWindow.classList.add 'hidden'; game.cacando = [paused, paused = game.cacando][0])

  getWidth: ->
    Math.max(document.documentElement.clientWidth, window.innerWidth || 0)
  getHeight: ->
    Math.max(document.documentElement.clientHeight, window.innerHeight || 0)

dom = new Dom()

