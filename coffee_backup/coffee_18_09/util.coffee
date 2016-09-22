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
