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
