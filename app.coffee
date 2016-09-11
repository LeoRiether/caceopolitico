class Politico
  constructor: (@name, @unblock, img, audio) ->
    @img = "img/#{img}.png"
    @audio = "audio/#{audio}"
  blocked: yes

class App
  constructor: ->
    App.self = this
    do cacheDom
    do bindEvents
    do initAudio
    do @makePolitico

  dom = {}
  cacheDom = ->
    dom = {
      body: document.body,
      modal: document.querySelector('.modal'),
      repeatBtn: document.querySelector('.btn')
    };

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

  bindEvents = ->
    ael document, 'mousemove', throttle bodyMouseMove, 80
    ael dom.body, 'click', bodyClick
    ael dom.repeatBtn, 'click', repeatBtnClick

  dist = (x0, y0, x1, y1) ->
    dx = x1 - x0
    dy = y1 - y0
    Math.sqrt dx*dx + dy*dy

  mouseRange = { s: 80 }
  mdist = -1
  cacando = yes
  bodyMouseMove = ({ clientX: x, clientY: y }) =>
    return if not cacando
    mdist = dist(x, y, politico.x, politico.y)
    clearInterval audioItv
    if mdist < mouseRange.s
      audioItv = setInterval @self.playSound.bind(audio.beep), 150
      dom.body.style.background = '#21cc0e'
      dom.body.style.cursor = 'pointer'
    else
      audioItv = setInterval @self.playSound.bind(audio.beep), mdist*2
      if mdist < mouseRange.s + 100
        dom.body.style.background = '#e4dd27'
      else if mdist < mouseRange.s + 200
        dom.body.style.background = '#f27215'
      else if mdist < mouseRange.s + 300
        dom.body.style.background = '#f75c19'
      else
        dom.body.style.background = '#ff4d00'
      dom.body.style.cursor = ''


  bodyClick = =>
    return if not cacando
    if mdist < mouseRange.s
      dom.body.style.removeProperty 'background'
      dom.body.style.removeProperty 'cursor'
      do @self.makePoliticoImg
      countPoliticos++
      setTimeout @self.showModal, 1000
      cacando = no
      mdist = mouseRange.s+1

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
    new Politico 'Temer', 0, 'temer', 'beep.mp3',
    new Politico 'Dilma', 5, 'dilma', 'beep.mp3'
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
  audioItv = undefined
  getAudio: -> audio
  audioCtx = undefined
  audioSource = undefined
  ajaxAudio = (url, key) ->
    req = new XMLHttpRequest()
    req.open 'GET', url, yes
    req.responseType = 'arraybuffer'
    req.onload = ->
      audioCtx.decodeAudioData req.response, ((buff) -> audio[key] = buff)
    do req.send

  initAudio = ->
    try
      window.AudioContext = window.AudioContext||window.webkitAudioContext;
      audioCtx = new AudioContext();
      ajaxAudio 'audio/beep.mp3', 'beep'
    catch
      alert('Web Audio API não é suportado em seu browser');

  playSound: (buff) ->
    return
    audioSource = audioSource || do audioCtx.createBufferSource
    audioSource.buffer = buff;
    audioSource.connect audioCtx.destination
    audioSource.start 0




@addEventListener 'load', -> window.app = new App()
