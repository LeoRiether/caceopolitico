ajax = (url, fn, respType) ->
  req = new XMLHttpRequest()
  req.open 'GET', url, yes
  req.responseType = respType if respType?
  req.onload = fn.bind null, req if fn?
  do req.send

class Politico
  constructor: (@name, @unblock, img, audio) ->
    @img = "img/#{img}.png"
    @audio = "audio/#{audio}.mp3"
    @audioKey = audio
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

class Game
  mouseRange: [ 100, 500, 1000, 2000 ]
  mdist: Game::mouseRange[1]
  politico: {}
  politicoIdx: 0
  cacando: no
  politicos = [
    new Politico 'Temer', 0, 'temer', 'beep'
    new Politico 'Dilma', 5, 'Dilma', 'beep'
    new Politico 'Cunha', 10, 'Cunha', 'beep'
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

  triggerAfterModalAnim: =>
    do dom.setModalPontos
    do dom.showModal
    do @removePoliticoImg

  bodyClick: =>
    return if not @cacando
    if @mdist < @mouseRange[0]
      dom.body.style.removeProperty 'background'
      dom.body.style.removeProperty 'cursor'
      do @makePoliticoImg
      storage.addPontos()
      setTimeout @triggerAfterModalAnim, 1000
      @cacando = no
      @mdist = @mouseRange[0]+1

  startBtnClick: =>
    @cacando = yes
    dom.startModal.classList.add 'hidden'
    #setTimeout (-> dom.startModal.remove()), 800
    do @makePolitico

  repeatBtnClick: =>
    return if @cacando
    setTimeout (=> @cacando = yes), 800
    do @removePoliticoImg
    do @makePolitico
    do dom.hideModal

  getWidth = ->
    Math.max(document.documentElement.clientWidth, window.innerWidth || 0)
  getHeight = ->
    Math.max(document.documentElement.clientHeight, window.innerHeight || 0)

  makePolitico: ->
    w = do getWidth
    h = do getHeight
    @politico = politicos[@politicoIdx]
    @politico.x = Math.floor Math.random() * (w-100) + 100
    @politico.y = Math.floor Math.random() * (h-100) + 100
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

class Dom
  constructor: ->
    @body = document.body
    @modal = document.querySelector '.modal'
    @modalPontos = @modal.querySelector '.pontos'
    @repeatBtn = @modal.querySelector '.btn'
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
    ael @repeatBtn, 'click', game.repeatBtnClick
    ael @startBtn, 'click', game.startBtnClick
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

  hideModal: ->
    dom.modal.classList.add 'hidden'
  showModal: ->
    dom.modal.classList.remove 'hidden'
  toggleModal: ->
    dom.modal.classList.toggle 'hidden'

  setModalPontos: ->
    dom.modalPontos.innerHTML = storage.pontos

dom = new Dom()

