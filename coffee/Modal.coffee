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
