len = (a) -> a.length
type = (a) -> typeof a
chr = (a) -> String.fromCharCode a
ord = (a) -> a.charCodeAt 0
Array::extend = (a) ->
    for i in [0 .. a.length-1]
        @push a[i]
b64encode=(a)->
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
napisWListę = (napis) ->
    lista = []
    tmczLista = [0 for i in [0 .. 6]]
    bajtów = 0
    for lit in napis
        nr = ord lit
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

#
nieujemne = (tablica) ->
    wynik = []
    for i in tablica
        if i >= 0
            wynik.push(i)
    wynik

wpasuj = (tekst) ->
    tekst = tekst.replace('\r\n','\n').replace('\r','\n')
    tekst = tekst.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
    tekst = tekst.split('\n')
    wynik=[]
    for i in tekst
        for j in podziel_linie(i)
            wynik.push(j)
    return wynik

podziel_linie = (tekst) ->
    wynik = ['']
    postoj = 0
    tekst = tekst.replace('\t',' ') # do naprawy
    while tekst
        miejsce_rozdzielaczy = (tekst.indexOf(i) for i in ROZDZIELACZE)
        miejsce_rozdzielaczy = nieujemne(miejsce_rozdzielaczy)
        if len(miejsce_rozdzielaczy)
            miejsce_rozdzielaczy = miejsce_rozdzielaczy.sort()
            pierwszy_rozdzielacz = miejsce_rozdzielaczy[0]
            wyraz = tekst[..pierwszy_rozdzielacz+1]
        else
            wyraz = tekst
        liter_w_wyrazie = len(wyraz)
        if postoj+liter_w_wyrazie < SZEROKOSC_STRONY
            wynik[wynik.length-1] += wyraz
            postoj += len(wyraz)
        else if liter_w_wyrazie < SZEROKOSC_STRONY
            wynik.push(wyraz)
            postoj = len(wyraz)
        else
            wolnego=SZEROKOSC_STRONY - postoj
            wynik[wynik.length-1] += wyraz[..wolnego]
            postoj += len(wyraz)
            wyraz = wyraz[wolnego..]
            while len(wyraz) > SZEROKOSC_STRONY
                wynik.push(wyraz[..SZEROKOSC_STRONY])
                postoj = len(wyraz)
                wyraz = wyraz[SZEROKOSC_STRONY..]
            wynik.push(wyraz)
            postoj = len(wyraz)
        tekst = tekst[liter_w_wyrazie..]
    return wynik

rozdziel_liczbe = (duza,conajmniej=1) ->
    if duza <= 0
        return (0 for i in [1..conajmniej])
    i = 0
    wynik = []
    while duza
        podwynik=parseInt(duza / Math.pow(256,i)) % 256
        duza -= podwynik * Math.pow(256,i)
        wynik.push(podwynik)
        i+=1
    while len(wynik) < conajmniej
        wynik.push(0)
    wynik.reverse()
    return wynik

doklej = (cos,conajmniej=1) ->
    if Array.isArray(cos)
        wiadomosc.extend cos
    else if (type '') == type cos
        wiadomosc.extend napisWListę cos
    else if (type 0) == type cos
        wiadomosc.extend rozdziel_liczbe cos, conajmniej

prostokat = (prawo,dol,szerokosc=1,wysokosc=1,kolor=[0,0,0],krycie=255) ->
    tablica = [0x42]
    tablica.extend( rozdziel_liczbe(prawo,2) )
    tablica.extend( rozdziel_liczbe(dol,3) )
    tablica.extend( rozdziel_liczbe(szerokosc,2) )
    tablica.extend( rozdziel_liczbe(wysokosc,3) )
    tablica.push(krycie)
    tablica.extend(kolor)
    return tablica

###
liczba_w_ascii = (liczba,conajmniej=1) ->
    wynik = ''
    for i in rozdziel_liczbe(liczba,conajmniej)
        wynik += chr(i)
    return wynik
###


ROZDZIELACZE = ' ,.:;/' # ?!_)]}+=-*
SZEROKOSC_STRONY = 38
wiadomosc = []

jdzo = () ->

    postoj = 0
    linie = ['']
    tytul = ':)'
    adres = 'http://www.example.com/'

    linie = wpasuj(document.body.textContent)

    i = 1

    doklej(12)
    doklej(310,2)
    doklej(16*len(linie)+16,3)
    doklej(0x530000ffff)
    doklej(len(tytul),2) # dl. tyt.
    doklej(tytul)
    doklej(0,4) # dl. porcji; dl. cz. wsp. lacz
    doklej(len(adres),2)
    doklej(adres)
    doklej(0x1b38000000)
    doklej('MC')
    doklej(0,3)
    doklej('Mu')
    doklej(0,7)
    doklej('S')
    doklej(0,3)
    doklej( prostokat(0,0,319,16*len(linie)+16,[255,255,240]) )

    for linia in linie
        if !linia then continue
        doklej('T')
        doklej(8,2)
        doklej(i*16,3)
        doklej(parseInt(320/37*len(linia)),2)
        doklej(16,3)
        doklej(255)
        doklej(0,3) #kolor
        doklej(0) #wyglad
        doklej(len(napisWListę(linia)),2)
        doklej(linia)
        i += 1

    # wiadomosc = liczba_w_ascii(len(wiadomosc),3) + wiadomosc
    ostatecznie = rozdziel_liczbe(len(wiadomosc),3)
    ostatecznie.extend wiadomosc
    wiadomosc = ostatecznie

    # plik = open(argv[1]+'.obml','wb')
    # plik.write(wiadomosc)
    # plik.close()

    location.href = 'data:application/octetstream;base64,' + b64encode(wiadomosc)

jdzo()