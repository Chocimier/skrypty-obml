zbudujObml = () ->
    console.log 'wewnętrzne operacje, m.in. parsowanie'
    html2canvas [document.body], {onrendered: ((a) -> location.href = 'data:application/octet-stream;base64,' + a.wynik), renderer: 'Obml'}

Array::extend = (a) ->
    for i in [0 .. a.length-1]
        @push a[i]

b64encode = (a) ->
    wynik=''
    cyfry='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    if 'string'==typeof a
        a=napisWListę a
    while a.length>=3 #for?
        b=a[0]*65536+a[1]*256+a[2]
        a=a[3..] # brzydkie
        wynik+=cyfry[b/262144%64|0]
        wynik+=cyfry[b/4096%64|0]
        wynik+=cyfry[b/64%64|0]
        wynik+=cyfry[b%64|0]
    switch a.length # na początek?
        when 2
            b=a[0]*65536+a[1]*256
            wynik+=cyfry[b/262144%64|0]
            wynik+=cyfry[b/4096%64|0]
            wynik+=cyfry[b/64%64|0]
            wynik+='='
        when 1
            b=a[0]*65536
            wynik+=cyfry[b/262144%64|0]
            wynik+=cyfry[b/4096%64|0]
            wynik+='=='
    return wynik

rozdziel_liczbe = (duza,conajmniej=1) ->
    if duza <= 0
        return (0 for i in [1..conajmniej])
    wynik = []
    while duza
        podwynik = duza%256
        duza -= podwynik
        duza /= 256
        wynik.unshift podwynik
    while wynik.length < conajmniej
        wynik.unshift 0
    return wynik

napisWListę = (napis) ->
    lista = []
    tmczLista = [0 for i in [0 .. 6]]
    bajtów = 0
    for lit in napis
        nr = lit.charCodeAt 0
        for i, j in [0, 128, 2048, 65536, 2097152, 67108864, 2147483648]
            if nr < i
                bajtów = j
                break
        if bajtów > 1
            for i in [bajtów .. 2] by -1
                tmczLista[i] = nr % 64 + 128
                nr -= nr % 64
                nr /= 64
        tmczLista[1] = nr + [0, 0, 192, 224, 240, 248, 252][bajtów]
        for i in [1 .. bajtów]
            lista.push tmczLista[i]
    lista

prostokat = (prawo,dol,szerokosc=1,wysokosc=1,kolor=[0,0,0],krycie=255) ->
    tablica = [0x42]
    tablica.extend( rozdziel_liczbe(prawo,2) )
    tablica.extend( rozdziel_liczbe(dol,3) )
    tablica.extend( rozdziel_liczbe(szerokosc,2) )
    tablica.extend( rozdziel_liczbe(wysokosc,3) )
    tablica.push(krycie)
    tablica.extend(kolor)
    return tablica

budujObml = (zStack, options, doc, queue, _html2canvas) ->
    ### kreślidło ###
    console.log 'budowa pliku obml ruszyła'

    doklej = (cos,conajmniej=1) ->
        if Array.isArray(cos)
            wynik.extend cos
        else if (typeof '') == typeof cos
            wynik.extend napisWListę cos
        else if (typeof 0) == typeof cos
            wynik.extend rozdziel_liczbe cos, conajmniej
    wynik = []

    wyglądCzcionki = 0
    wysokośćLiter = 10
    [Cz, Zl, Nb] = [0,0,0]
    położenieNapisu = 'right'
    poprawkaGóry = 0
    poprawkaLewa = 0

    tytuł = document.title
    adres = location.href

    console.log 'wymiary', options, options.width, options.height

    doklej 12
    doklej document.body.clientWidth, 2
    doklej document.body.clientHeight, 3
    doklej [83, 0, 0, 255, 255]
    doklej tytuł.length, 2 # dl. tyt.
    doklej tytuł
    doklej 0, 4 # favikona, dl. cz. wsp. lacz
    doklej adres.length, 2
    doklej adres
    doklej [0x1b, 0x4b, 0, 0xf1, 0x88] # porcja III, przykład
    doklej 'MC'
    doklej 0, 3
    doklej 'Mu'
    doklej 0, 7
    doklej 'S'
    doklej 0, 3
    doklej prostokat 0, 0, document.body.clientWidth, document.body.clientHeight, [255, 255, 255]

    console.log 'rysowanie'
    for storageContext in queue
        if !storageContext.ctx.storage
            continue
        if storageContext.clip
            poprawkaGóry = storageContext.clip.top
            poprawkaLewa = storageContext.clip.left
        for renderItem in storageContext.ctx.storage
            switch renderItem.type
                when 'variable'
                    switch renderItem.name
                        when 'fillStyle'
                            [Cz, Zl, Nb] = (parseInt i for i in renderItem.arguments.match /\d+/g)
                        when 'font'
                            ###
                            style - pochyłość - pomijamy
                            variant - małe kształtu wielkich - pomijamy
                            weight - grubość
                            size - wysokość
                            family - krój - pomijamy
                            ###
                            plastry = renderItem.arguments.split ' '
                            wyglądCzcionki = 0
                            wysokośćLiter = 10
                            if (plastry[2].match 'bold') or (550 < plastry[2].match /d+/)
                                wyglądLiter += 1
                            if (plastry[3].match /\d+/) > 20 #wielkie
                                wyglądCzcionki += 2
                                wysokośćLiter = 20
                            if 14 < (renderItem.arguments.match /\d+/) < 21 #średnie
                                wyglądCzcionki += 4
                                wysokośćLiter = 14
                        when 'textAlign'
                            położenieNapisu = renderItem.arguments
                when 'function'
                    switch renderItem.name
                        when 'fillRect'
                            lewo = poprawkaLewa+renderItem.arguments[0]
                            góra = poprawkaGóry+renderItem.arguments[1]
                            continue if lewo<0 || góra<0
                            wynik.push 66 #B
                            wynik.extend rozdziel_liczbe lewo, 2
                            wynik.extend rozdziel_liczbe góra, 3
                            wynik.extend rozdziel_liczbe renderItem.arguments[2], 2
                            wynik.extend rozdziel_liczbe renderItem.arguments[3], 3
                            wynik.extend [255, Cz, Zl, Nb]
                        when 'fillText'
                            lewo = poprawkaLewa+renderItem.arguments[1]
                            góra = poprawkaGóry+renderItem.arguments[2] - wysokośćLiter
                            continue if lewo<0 || góra<0
                            bajty = napisWListę renderItem.arguments[0]
                            wynik.push 84 #T
                            wynik.extend rozdziel_liczbe lewo, 2
                            wynik.extend rozdziel_liczbe góra, 3
                            wynik.extend [0, 10, 0, 0, 10, 255, Cz, Zl, Nb, wyglądCzcionki]
                            wynik.extend rozdziel_liczbe bajty.length, 2
                            wynik.extend bajty
    #                     when 'drawImage'
    #                         console.log 'obrazek', renderItem.arguments
        poprawkaGóry = poprawkaLewa = 0
    ostatecznie = rozdziel_liczbe wynik.length, 3
    ostatecznie.extend wynik
    wynik = ostatecznie
    console.log 'kodowanie do b64'
    wynik = b64encode wynik
    console.log 'koniec'
    return {'wynik': wynik}
