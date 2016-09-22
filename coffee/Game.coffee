class Game
  mouseRange: [ 100, 500, 1000, 2000 ]
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
      @mdist = @mouseRange[0]+1

  makePolitico: ->
    w = do dom.getWidth
    h = do dom.getHeight
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
