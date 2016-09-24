#= require Audio

ajax = (url, fn, respType) ->
  req = new XMLHttpRequest()
  req.open 'GET', url, yes
  req.responseType = respType if respType?
  req.onload = fn.bind null, req if fn?
  do req.send

class Politico
  constructor: (@name, @unblock, img, @audioKey, @blocked) ->
    @img = "img/#{img}.png"
    #@audio = ("audio/#{audioKey}/#{audioKey}00#{i}.wav" for i in [1..4])
    @audio = (for i in [1..4]
      k = "#{@audioKey}00#{i}"
      l = "audio/#{@audioKey}/#{k}.wav"
      audio.ajaxAudio l, k
      k
    )

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
