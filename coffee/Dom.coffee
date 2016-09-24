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
    @polListStart.forEach ((li, i) =>
      ael li, 'click', ((e) =>
        return if game.politicos[i].blocked()
        game.politicoIdx = i
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
modal.updatePoliticosStart()
