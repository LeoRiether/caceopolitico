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

class App
  constructor: ->
    App.self = this
    do cacheDom
    do bindEvents
    do initAudio
    #do initImg
    #do @makePolitico

  dom = {}
  cacheDom = ->
    dom.body = document.body
    dom.modal = document.querySelector('.modal')
    dom.repeatBtn = dom.modal.querySelector('.btn')
    dom.startModal = document.querySelector('.start-modal')
    dom.startBtn = dom.startModal.querySelector('.btn')

  bindEvents = ->
    ael document, 'mousemove', throttle bodyMouseMove, 80
    ael document, 'touchmove', throttle bodyTouchMove, 80
    ael dom.body, 'click', bodyClick
    ael dom.repeatBtn, 'click', repeatBtnClick
    ael dom.startBtn, 'click', startBtnClick

  hideModal: ->
    dom.modal.classList.add 'hidden'
  showModal: ->
    dom.modal.classList.remove 'hidden'
  toggleModal: ->
    dom.modal.classList.toggle 'hidden'

  ael = (d, e, l) ->
    d.addEventListener e, l

  throttle = (f, d) ->
    t = no
    ->
      return if t
      t = yes
      setTimeout (-> t = no), d
      f arguments...

  dist = (x0, y0, x1, y1) ->
    dx = x1 - x0
    dy = y1 - y0
    Math.sqrt dx*dx + dy*dy

  #mouseRange = [ 10, 50, 200, 400 ]
  mouseRange = [ 50, 100, 200, 400 ]
  mdist = mouseRange[1]
  cacando = no
  bodyMouseMove = ({ clientX: x, clientY: y }) =>
    return if not cacando
    mdist = dist(x, y, politico.x, politico.y)
    if mdist < mouseRange[0]
      dom.body.style.cursor = 'pointer'
    else
      dom.body.style.cursor = ''

  bodyTouchMove = ({ touches: [ a ] }) =>
    bodyMouseMove(a);

  bodyClick = =>
    return if not cacando
    if mdist < mouseRange[0]
      dom.body.style.removeProperty 'background'
      dom.body.style.removeProperty 'cursor'
      do @self.makePoliticoImg
      countPoliticos++
      setTimeout @self.showModal, 1000
      cacando = no
      mdist = mouseRange.s+1

  startBtnClick = =>
    cacando = yes
    dom.startModal.classList.add 'hidden'
    setTimeout (-> dom.startModal.remove()), 800
    do @self.makePolitico

  repeatBtnClick = =>
    return if cacando
    setTimeout (-> cacando = yes), 800
    #cacando = yes
    do @self.removePoliticoImg
    do @self.makePolitico
    do @self.hideModal

  getWidth = ->
    Math.max(document.documentElement.clientWidth, window.innerWidth || 0)
  getHeight = ->
    Math.max(document.documentElement.clientHeight, window.innerHeight || 0)

  politico = {}
  countPoliticos = 0
  politicos = [
    new Politico 'Temer', 0, 'Temer', 'beep',
    new Politico 'Dilma', 5, 'Dilma', 'beep',
    new Politico 'Cunha', 10, 'Cunha', 'beep'
  ]
  makePolitico: ->
    w = do getWidth
    h = do getHeight
    politico = politicos[0]
    politico.x = Math.floor Math.random() * (w-100) + 100
    politico.y = Math.floor Math.random() * (h-100) + 100
    console.info "#{politico.name} #{politico.x} #{politico.y} #{politico.img} #{politico.audio}"

  makePoliticoImg: ->
    img = document.createElement 'img'
    img.setAttribute 'src', politico.img
    img.classList.add 'polImg'
    img.style.left = "#{politico.x}px"
    img.style.top = "#{politico.y}px"
    dom.body.appendChild img

  removePoliticoImg: ->
    polImg = document.querySelector('.polImg')
    do polImg.remove if polImg

  audio = {}
  getAudio: -> audio
  audioItv = undefined
  audioCtx = undefined
  audioSource = undefined
  ajaxAudio = (url, key) ->
    ajax url, ((req) -> audioCtx.decodeAudioData req.response, ((buff) -> audio[key] = buff)), 'arraybuffer'

  initAudio = =>
    try
      window.AudioContext = window.AudioContext||window.webkitAudioContext;
      audioCtx = new window.AudioContext();
      ajaxAudio 'audio/beep.mp3', 'beep'
      audioItv = setInterval @self.playSound, 100
    catch
      alert('Web Audio API não é suportado em seu browser');

  canPlaySound = yes
  setCanPlaySound = ->
    canPlaySound = yes
  playSound: ->
    return if not canPlaySound or cacando
    setTimeout setCanPlaySound,
    canPlaySound = no
    audioSource = do audioCtx.createBufferSource
    audioSource.buffer = audio[politico.audioKey];
    audioSource.connect audioCtx.destination
    audioSource.start 0

  initImg = ->
    ajax pol.img for pol in politicos




@addEventListener 'load', -> window.app = new App()
