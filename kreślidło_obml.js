var b64encode, budujObml, napisWListę, prostokat, rozdziel_liczbe, zbudujObml;

zbudujObml = function() {
  console.log('wewnętrzne operacje, m.in. parsowanie');
  return html2canvas([document.body], {
    onrendered: (function(a) {
      return location.href = 'data:application/octet-stream;base64,' + a.wynik;
    }),
    renderer: 'Obml'
  });
};

Array.prototype.extend = function(a) {
  var i, _i, _ref, _results;
  _results = [];
  for (i = _i = 0, _ref = a.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
    _results.push(this.push(a[i]));
  }
  return _results;
};

b64encode = function(a) {
  var b, cyfry, wynik;
  wynik = '';
  cyfry = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  if ('string' === typeof a) {
    a = napisWListę(a);
  }
  while (a.length >= 3) {
    b = a[0] * 65536 + a[1] * 256 + a[2];
    a = a.slice(3);
    wynik += cyfry[b / 262144 % 64 | 0];
    wynik += cyfry[b / 4096 % 64 | 0];
    wynik += cyfry[b / 64 % 64 | 0];
    wynik += cyfry[b % 64 | 0];
  }
  switch (a.length) {
    case 2:
      b = a[0] * 65536 + a[1] * 256;
      wynik += cyfry[b / 262144 % 64 | 0];
      wynik += cyfry[b / 4096 % 64 | 0];
      wynik += cyfry[b / 64 % 64 | 0];
      wynik += '=';
      break;
    case 1:
      b = a[0] * 65536;
      wynik += cyfry[b / 262144 % 64 | 0];
      wynik += cyfry[b / 4096 % 64 | 0];
      wynik += '==';
  }
  return wynik;
};

rozdziel_liczbe = function(duza, conajmniej) {
  var i, podwynik, wynik;
  if (conajmniej == null) {
    conajmniej = 1;
  }
  if (duza <= 0) {
    return (function() {
      var _i, _results;
      _results = [];
      for (i = _i = 1; 1 <= conajmniej ? _i <= conajmniej : _i >= conajmniej; i = 1 <= conajmniej ? ++_i : --_i) {
        _results.push(0);
      }
      return _results;
    })();
  }
  wynik = [];
  while (duza) {
    podwynik = duza % 256;
    duza -= podwynik;
    duza /= 256;
    wynik.unshift(podwynik);
  }
  while (wynik.length < conajmniej) {
    wynik.unshift(0);
  }
  return wynik;
};

napisWListę = function(napis) {
  var bajtów, i, j, lista, lit, nr, tmczLista, _i, _j, _k, _l, _len, _len1, _ref;
  lista = [];
  tmczLista = [
    (function() {
      var _i, _results;
      _results = [];
      for (i = _i = 0; _i <= 6; i = ++_i) {
        _results.push(0);
      }
      return _results;
    })()
  ];
  bajtów = 0;
  for (_i = 0, _len = napis.length; _i < _len; _i++) {
    lit = napis[_i];
    nr = lit.charCodeAt(0);
    _ref = [0, 128, 2048, 65536, 2097152, 67108864, 2147483648];
    for (j = _j = 0, _len1 = _ref.length; _j < _len1; j = ++_j) {
      i = _ref[j];
      if (nr < i) {
        bajtów = j;
        break;
      }
    }
    if (bajtów > 1) {
      for (i = _k = bajtów; _k >= 2; i = _k += -1) {
        tmczLista[i] = nr % 64 + 128;
        nr -= nr % 64;
        nr /= 64;
      }
    }
    tmczLista[1] = nr + [0, 0, 192, 224, 240, 248, 252][bajtów];
    for (i = _l = 1; 1 <= bajtów ? _l <= bajtów : _l >= bajtów; i = 1 <= bajtów ? ++_l : --_l) {
      lista.push(tmczLista[i]);
    }
  }
  return lista;
};

prostokat = function(prawo, dol, szerokosc, wysokosc, kolor, krycie) {
  var tablica;
  if (szerokosc == null) {
    szerokosc = 1;
  }
  if (wysokosc == null) {
    wysokosc = 1;
  }
  if (kolor == null) {
    kolor = [0, 0, 0];
  }
  if (krycie == null) {
    krycie = 255;
  }
  tablica = [0x42];
  tablica.extend(rozdziel_liczbe(prawo, 2));
  tablica.extend(rozdziel_liczbe(dol, 3));
  tablica.extend(rozdziel_liczbe(szerokosc, 2));
  tablica.extend(rozdziel_liczbe(wysokosc, 3));
  tablica.push(krycie);
  tablica.extend(kolor);
  return tablica;
};

budujObml = function(zStack, options, doc, queue, _html2canvas) {
  /* kreślidło
  */

  var Cz, Nb, Zl, adres, bajty, doklej, góra, i, lewo, ostatecznie, plastry, poprawkaGóry, poprawkaLewa, położenieNapisu, renderItem, storageContext, tytuł, wyglądCzcionki, wynik, wysokośćLiter, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
  console.log('budowa pliku obml ruszyła');
  doklej = function(cos, conajmniej) {
    if (conajmniej == null) {
      conajmniej = 1;
    }
    if (Array.isArray(cos)) {
      return wynik.extend(cos);
    } else if ((typeof '') === typeof cos) {
      return wynik.extend(napisWListę(cos));
    } else if ((typeof 0) === typeof cos) {
      return wynik.extend(rozdziel_liczbe(cos, conajmniej));
    }
  };
  wynik = [];
  wyglądCzcionki = 0;
  wysokośćLiter = 10;
  _ref = [0, 0, 0], Cz = _ref[0], Zl = _ref[1], Nb = _ref[2];
  położenieNapisu = 'right';
  poprawkaGóry = 0;
  poprawkaLewa = 0;
  tytuł = document.title;
  adres = location.href;
  console.log('wymiary', options, options.width, options.height);
  doklej(12);
  doklej(document.body.clientWidth, 2);
  doklej(document.body.clientHeight, 3);
  doklej([83, 0, 0, 255, 255]);
  doklej(tytuł.length, 2);
  doklej(tytuł);
  doklej(0, 4);
  doklej(adres.length, 2);
  doklej(adres);
  doklej([0x1b, 0x4b, 0, 0xf1, 0x88]);
  doklej('MC');
  doklej(0, 3);
  doklej('Mu');
  doklej(0, 7);
  doklej('S');
  doklej(0, 3);
  doklej(prostokat(0, 0, document.body.clientWidth, document.body.clientHeight, [255, 255, 255]));
  console.log('rysowanie');
  for (_i = 0, _len = queue.length; _i < _len; _i++) {
    storageContext = queue[_i];
    if (!storageContext.ctx.storage) {
      continue;
    }
    if (storageContext.clip) {
      poprawkaGóry = storageContext.clip.top;
      poprawkaLewa = storageContext.clip.left;
    }
    _ref1 = storageContext.ctx.storage;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      renderItem = _ref1[_j];
      switch (renderItem.type) {
        case 'variable':
          switch (renderItem.name) {
            case 'fillStyle':
              _ref2 = (function() {
                var _k, _len2, _ref2, _results;
                _ref2 = renderItem["arguments"].match(/\d+/g);
                _results = [];
                for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
                  i = _ref2[_k];
                  _results.push(parseInt(i));
                }
                return _results;
              })(), Cz = _ref2[0], Zl = _ref2[1], Nb = _ref2[2];
              break;
            case 'font':
              /*
                                          style - pochyłość - pomijamy
                                          variant - małe kształtu wielkich - pomijamy
                                          weight - grubość
                                          size - wysokość
                                          family - krój - pomijamy
              */

              plastry = renderItem["arguments"].split(' ');
              wyglądCzcionki = 0;
              wysokośćLiter = 10;
              if ((plastry[2].match('bold')) || (550 < plastry[2].match(/d+/))) {
                wyglądLiter += 1;
              }
              if ((plastry[3].match(/\d+/)) > 20) {
                wyglądCzcionki += 2;
                wysokośćLiter = 20;
              }
              if ((14 < (_ref3 = renderItem["arguments"].match(/\d+/)) && _ref3 < 21)) {
                wyglądCzcionki += 4;
                wysokośćLiter = 14;
              }
              break;
            case 'textAlign':
              położenieNapisu = renderItem["arguments"];
          }
          break;
        case 'function':
          switch (renderItem.name) {
            case 'fillRect':
              lewo = poprawkaLewa + renderItem["arguments"][0];
              góra = poprawkaGóry + renderItem["arguments"][1];
              if (lewo < 0 || góra < 0) {
                continue;
              }
              wynik.push(66);
              wynik.extend(rozdziel_liczbe(lewo, 2));
              wynik.extend(rozdziel_liczbe(góra, 3));
              wynik.extend(rozdziel_liczbe(renderItem["arguments"][2], 2));
              wynik.extend(rozdziel_liczbe(renderItem["arguments"][3], 3));
              wynik.extend([255, Cz, Zl, Nb]);
              break;
            case 'fillText':
              lewo = poprawkaLewa + renderItem["arguments"][1];
              góra = poprawkaGóry + renderItem["arguments"][2] - wysokośćLiter;
              if (lewo < 0 || góra < 0) {
                continue;
              }
              bajty = napisWListę(renderItem["arguments"][0]);
              wynik.push(84);
              wynik.extend(rozdziel_liczbe(lewo, 2));
              wynik.extend(rozdziel_liczbe(góra, 3));
              wynik.extend([0, 10, 0, 0, 10, 255, Cz, Zl, Nb, wyglądCzcionki]);
              wynik.extend(rozdziel_liczbe(bajty.length, 2));
              wynik.extend(bajty);
          }
      }
    }
    poprawkaGóry = poprawkaLewa = 0;
  }
  ostatecznie = rozdziel_liczbe(wynik.length, 3);
  ostatecznie.extend(wynik);
  wynik = ostatecznie;
  console.log('kodowanie do b64');
  wynik = b64encode(wynik);
  console.log('koniec');
  return {
    'wynik': wynik
  };
};
