#!/usr/bin/env python2
#coding:utf8

from sys import argv

def nieujemne(tablica):
    wynik = []
    for i in tablica:
        if i >= 0:
            wynik.append(i)
    return wynik

def wpasuj(tekst):
    tekst = tekst.replace('\r\n','\n').replace('\r','\n')
    tekst = tekst.split('\n')
    wynik=[]
    for i in tekst:
        for j in podziel_linie(i):
            wynik.append(j)
    return wynik

def podziel_linie(tekst):
    wynik = ['']
    postoj = 0
    tekst = tekst.replace('\t',' ') # do naprawy
    while tekst:
        miejsce_rozdzielaczy = [tekst.find(i) for i in ROZDZIELACZE]
        miejsce_rozdzielaczy = nieujemne(miejsce_rozdzielaczy)
        if miejsce_rozdzielaczy:
            miejsce_rozdzielaczy.sort()
            pierwszy_rozdzielacz = miejsce_rozdzielaczy[0]
            wyraz = tekst[:pierwszy_rozdzielacz+1]
        else:
            wyraz = tekst
        liter_w_wyrazie = len(wyraz)
        if postoj+liter_w_wyrazie < SZEROKOSC_STRONY:
            wynik[-1] += wyraz
            postoj += len(wyraz)
        elif liter_w_wyrazie < SZEROKOSC_STRONY:
            wynik.append(wyraz)
            postoj = len(wyraz)
        else:
            wolnego=SZEROKOSC_STRONY - postoj
            wynik[-1] += wyraz[:wolnego]
            postoj += len(wyraz)
            wyraz = wyraz[wolnego:]
            while len(wyraz) > SZEROKOSC_STRONY:
                wynik.append(wyraz[:SZEROKOSC_STRONY])
                postoj = len(wyraz)
                wyraz = wyraz[SZEROKOSC_STRONY:]
            wynik.append(wyraz)
            postoj = len(wyraz)
        tekst = tekst[liter_w_wyrazie:]
    return wynik

def scisnij(sciezka):
    SZEROKOSC_STRONY = 38
    ROZDZIELACZE = ' ,.:;/\\?!_{[()]}+=-*'
    plik = open(sciezka)
    tasiemiec = plik.read()
    plik.close()
    return wpasuj(tasiemiec)

def rozdziel_liczbe(duza,conajmniej=1):
    if duza <= 0:
        return [0 for i in range(conajmniej)]
    i = 0
    wynik = []
    while duza:
        podwynik=duza // 256**i % 256
        duza -= podwynik * 256**i
        wynik.append(podwynik)
        i+=1
    while len(wynik) < conajmniej:
        wynik.append(0)
    wynik.reverse()
    return wynik

def doklej(cos,conajmniej=1):
    global wiadomosc
    if type(cos) == type(''):
        wiadomosc += cos
    elif [type(0),type(0l)].count( type(cos) ):
        for i in rozdziel_liczbe(cos,conajmniej):
            wiadomosc += chr(i)

def prostokat(prawo,dol,szerokosc=1,wysokosc=1,kolor=[0,0,0],krycie=255):
    tablica = []
    wynik = 'B'
    tablica.extend( rozdziel_liczbe(prawo,2) )
    tablica.extend( rozdziel_liczbe(dol,3) )
    tablica.extend( rozdziel_liczbe(szerokosc,2) )
    tablica.extend( rozdziel_liczbe(wysokosc,3) )
    tablica.append(krycie)
    tablica.extend(kolor)
    for i in tablica:
        wynik += chr(i)
    return wynik

def liczba_w_ascii(liczba,conajmniej=1):
    wynik = ''
    for i in rozdziel_liczbe(liczba,conajmniej):
        wynik += chr(i)
    return wynik

SZEROKOSC_STRONY = 38
ROZDZIELACZE = ' ,.:;/' # ?!_)]}+=-*

postoj = 0
linie = ['']
wiadomosc = ''
tytul = ':)'
adres = 'http://www.example.com/'

linie = scisnij(argv[1])

i = 1

for linia in linie:
    doklej('T')
    doklej(8,2)
    doklej(i*16,3)
    doklej(320/37*len(linia.decode('utf8')),2)
    doklej(16,3)
    doklej(255)
    doklej(0,3) #kolor
    doklej(0) #wyglad
    doklej(len(linia),2)
    doklej(linia)
    i += 1

tresc = wiadomosc
wiadomosc =  ''
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
doklej(0,3)
doklej('S')
doklej(0,3)
doklej( prostokat(0,0,319,16*len(linie)+16,[255,255,240]) )

wiadomosc += tresc
wiadomosc = liczba_w_ascii(len(wiadomosc),3) + wiadomosc

plik = open(argv[1]+'.obml','wb')
plik.write(wiadomosc)
plik.close()
