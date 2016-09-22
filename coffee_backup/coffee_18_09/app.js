// Generated by CoffeeScript 1.10.0
(function() {
  var Audio, Dom, Game, Politico, Storage, ajax, audio, dom, game, storage,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  ajax = function(url, fn, respType) {
    var req;
    req = new XMLHttpRequest();
    req.open('GET', url, true);
    if (respType != null) {
      req.responseType = respType;
    }
    if (fn != null) {
      req.onload = fn.bind(null, req);
    }
    return req.send();
  };

  Politico = (function() {
    function Politico(name, unblock, img, audio) {
      this.name = name;
      this.unblock = unblock;
      this.img = "img/" + img + ".png";
      this.audio = "audio/" + audio + ".mp3";
      this.audioKey = audio;
    }

    Politico.prototype.blocked = true;

    return Politico;

  })();

  Storage = (function() {
    function Storage() {
      var pontos;
      pontos = parseInt(localStorage.pontos) || (localStorage.pontos = 0);
      Object.defineProperty(this, 'pontos', {
        get: (function(_this) {
          return function() {
            return pontos;
          };
        })(this),
        set: (function(_this) {
          return function(v) {
            return localStorage.pontos = pontos = v;
          };
        })(this),
        configurable: false
      });
    }

    Storage.prototype.addPontos = function(a) {
      if (a == null) {
        a = 1;
      }
      return this.pontos += a;
    };

    return Storage;

  })();

  storage = new Storage();

  Game = (function() {
    var dist, getHeight, getWidth, politicos;

    function Game() {
      this.repeatBtnClick = bind(this.repeatBtnClick, this);
      this.startBtnClick = bind(this.startBtnClick, this);
      this.bodyClick = bind(this.bodyClick, this);
      this.triggerAfterModalAnim = bind(this.triggerAfterModalAnim, this);
      this.bodyTouchMove = bind(this.bodyTouchMove, this);
      this.bodyMouseMove = bind(this.bodyMouseMove, this);
    }

    Game.prototype.mouseRange = [100, 500, 1000, 2000];

    Game.prototype.mdist = Game.prototype.mouseRange[1];

    Game.prototype.politico = {};

    Game.prototype.politicoIdx = 0;

    Game.prototype.cacando = false;

    politicos = [new Politico('Temer', 0, 'temer', 'beep'), new Politico('Dilma', 5, 'Dilma', 'beep'), new Politico('Cunha', 10, 'Cunha', 'beep')];

    Game.prototype.bodyMouseMove = function(arg) {
      var x, y;
      x = arg.clientX, y = arg.clientY;
      if (!this.cacando) {
        return;
      }
      this.mdist = dist(x, y, this.politico.x, this.politico.y);
      if (this.mdist < this.mouseRange[0]) {
        return dom.body.style.cursor = 'pointer';
      } else {
        return dom.body.style.cursor = '';
      }
    };

    Game.prototype.bodyTouchMove = function(arg) {
      var a;
      a = arg.touches[0];
      return this.bodyMouseMove(a);
    };

    dist = function(x0, y0, x1, y1) {
      var dx, dy;
      dx = x1 - x0;
      dy = y1 - y0;
      return Math.sqrt(dx * dx + dy * dy);
    };

    Game.prototype.triggerAfterModalAnim = function() {
      dom.setModalPontos();
      dom.showModal();
      return this.removePoliticoImg();
    };

    Game.prototype.bodyClick = function() {
      if (!this.cacando) {
        return;
      }
      if (this.mdist < this.mouseRange[0]) {
        dom.body.style.removeProperty('background');
        dom.body.style.removeProperty('cursor');
        this.makePoliticoImg();
        storage.addPontos();
        setTimeout(this.triggerAfterModalAnim, 1000);
        this.cacando = false;
        return this.mdist = this.mouseRange[0] + 1;
      }
    };

    Game.prototype.startBtnClick = function() {
      this.cacando = true;
      dom.startModal.classList.add('hidden');
      return this.makePolitico();
    };

    Game.prototype.repeatBtnClick = function() {
      if (this.cacando) {
        return;
      }
      setTimeout(((function(_this) {
        return function() {
          return _this.cacando = true;
        };
      })(this)), 800);
      this.removePoliticoImg();
      this.makePolitico();
      return dom.hideModal();
    };

    getWidth = function() {
      return Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
    };

    getHeight = function() {
      return Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
    };

    Game.prototype.makePolitico = function() {
      var a, h, w;
      w = getWidth();
      h = getHeight();
      this.politico = politicos[this.politicoIdx];
      this.politico.x = Math.floor(Math.random() * (w - 100) + 100);
      this.politico.y = Math.floor(Math.random() * (h - 100) + 100);
      a = document.querySelector('.hint');
      a.style.top = this.politico.y + 'px';
      return a.style.left = this.politico.x + 'px';
    };

    Game.prototype.makePoliticoImg = function() {
      var img;
      img = document.createElement('img');
      img.setAttribute('src', this.politico.img);
      img.classList.add('polImg');
      img.style.left = this.politico.x + "px";
      img.style.top = this.politico.y + "px";
      dom.body.appendChild(img);
      return dom.polImgModal.setAttribute('src', this.politico.img);
    };

    Game.prototype.removePoliticoImg = function() {
      var polImg;
      polImg = document.querySelector('.polImg');
      if (polImg) {
        return polImg.remove();
      }
    };

    return Game;

  })();

  game = new Game();

  Audio = (function() {
    var ajaxAudio, audio, audioCtx, audioItv, audioSource, canPlaySound, setCanPlaySound;

    audio = {};

    Audio.prototype.getAudio = function() {
      return audio;
    };

    audioItv = void 0;

    audioCtx = void 0;

    Audio.prototype.getAudioCtx = function() {
      return audioCtx;
    };

    audioSource = void 0;

    ajaxAudio = function(url, key) {
      return ajax(url, (function(req) {
        return audioCtx.decodeAudioData(req.response, (function(buff) {
          return audio[key] = buff;
        }));
      }), 'arraybuffer');
    };

    function Audio() {
      var error;
      try {
        window.AudioContext = window.AudioContext || window.webkitAudioContext;
        audioCtx = new window.AudioContext();
        ajaxAudio('audio/beep.mp3', 'beep');
        audioItv = setInterval(this.playSound, 100);
      } catch (error) {
        alert('Web Audio API não é suportado em seu browser');
      }
    }

    canPlaySound = true;

    setCanPlaySound = function() {
      return canPlaySound = true;
    };

    Audio.prototype.playSound = function() {
      if (!canPlaySound || !game.cacando) {
        return;
      }
      if (game.mdist < game.mouseRange[0]) {
        setTimeout(setCanPlaySound, 150);
      } else if (game.mdist < game.mouseRange[1]) {
        setTimeout(setCanPlaySound, 300);
      } else if (game.mdist < game.mouseRange[2]) {
        setTimeout(setCanPlaySound, 500);
      } else {
        setTimeout(setCanPlaySound, 800);
      }
      canPlaySound = false;
      audioSource = audioCtx.createBufferSource();
      audioSource.buffer = audio[game.politico.audioKey];
      audioSource.connect(audioCtx.destination);
      return audioSource.start(0);
    };

    return Audio;

  })();

  audio = new Audio();

  Dom = (function() {
    var ael, throttle;

    function Dom() {
      this.body = document.body;
      this.modal = document.querySelector('.modal');
      this.modalPontos = this.modal.querySelector('.pontos');
      this.repeatBtn = this.modal.querySelector('.btn');
      this.polImgModal = this.modal.querySelector('.polImgModal');
      this.startModal = document.querySelector('.start-modal');
      this.polListStart = this.startModal.querySelectorAll('.pol-list li');
      this.startBtn = this.startModal.querySelector('.btn');
      this.infoBtn = document.querySelector('.info-btn');
      this.infoWindow = document.querySelector('.info-window');
      this.closeInfo = this.infoWindow.querySelector('.close');
      this.bindEvents();
    }

    ael = function(d, e, l) {
      return d.addEventListener(e, l);
    };

    throttle = function(f, d) {
      var t;
      t = false;
      return function() {
        if (t) {
          return;
        }
        t = true;
        setTimeout((function() {
          return t = false;
        }), d);
        return f.apply(null, arguments);
      };
    };

    Dom.prototype.bindEvents = function() {
      var paused;
      ael(document, 'mousemove', throttle(game.bodyMouseMove, 80));
      ael(document, 'touchmove', throttle(game.bodyTouchMove, 80));
      ael(this.body, 'click', game.bodyClick);
      ael(this.repeatBtn, 'click', game.repeatBtnClick);
      ael(this.startBtn, 'click', game.startBtnClick);
      this.polListStart.forEach(((function(_this) {
        return function(li) {
          return ael(li, 'click', (function(e) {
            game.politicoIdx = parseInt(e.target.dataset.pol);
            _this.startModal.querySelector('.active').classList.remove('active');
            return li.classList.add('active');
          }));
        };
      })(this)));
      paused = false;
      ael(this.infoBtn, 'click', ((function(_this) {
        return function() {
          _this.infoWindow.classList.toggle('hidden');
          return game.cacando = [paused, paused = game.cacando][0];
        };
      })(this)));
      return ael(this.closeInfo, 'click', ((function(_this) {
        return function() {
          _this.infoWindow.classList.add('hidden');
          return game.cacando = [paused, paused = game.cacando][0];
        };
      })(this)));
    };

    Dom.prototype.hideModal = function() {
      return dom.modal.classList.add('hidden');
    };

    Dom.prototype.showModal = function() {
      return dom.modal.classList.remove('hidden');
    };

    Dom.prototype.toggleModal = function() {
      return dom.modal.classList.toggle('hidden');
    };

    Dom.prototype.setModalPontos = function() {
      return dom.modalPontos.innerHTML = storage.pontos;
    };

    return Dom;

  })();

  dom = new Dom();

}).call(this);
