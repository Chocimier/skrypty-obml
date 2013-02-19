#!/usr/bin/env python3
#coding:utf8

from sys import argv, stderr
from base64 import b64encode
import os

# ustawienia
svgz='nie' # nie, większe, mniejsze, tak

# informacje o przebiegu pracy
mrucz=[
    'złe',
    #'dobre',
    #'dobre krótko',
    #'dobre b. krótko',
    #'wymiary',
    #'I',
    #'F',
    #'F²',
    #'pierwszy S',
    #'nieznane',
    #'porcja I',
    'plik',
    #'objętość',
    #'ikona',
    #'tytuł',
    #'zaadresie',
    #'Mu',
    #'MC',
    #'T',
    #'obrazki',
    #'certyfikat',
]
# „stałe”
rodzajePól={
    97  : ['textarea',False],
    99  : ['input','checkbox'],
    112 : ['input','password'],
    114 : ['input','radio'],
    115 : ['select',False],
    120 : ['input','text']
}
poprawkiPól={'input':[2,6,6],'select':[0,18,0],'textarea':[0,0,0]}
listaKolorów={'#c0c0c0':'silver','#808080':'gray','#800000':'maroon','#ff0000':'red','#800080':'purple','#008000':'green','#808000':'olive','#000080':'navy','#008080':'teal','#f0ffff':'azure','#f5f5dc':'beige','#ffe4c4':'bisque','#a52a2a':'brown','#ff7f50':'coral','#ffd700':'gold','#4b0082':'indigo','#fffff0':'ivory','#f0e68c':'khaki','#faf0e6':'linen','#da70d6':'orchid','#cd853f':'peru','#ffc0cb':'pink','#dda0dd':'plum','#fa8072':'salmon','#a0522d':'sienna','#fffafa':'snow','#d2b48c':'tan','#ff6347':'tomato','#ee82ee':'violet','#f5deb3':'wheat'}
CSS='\ttext {font-size:12px;font-family:sans-serif}\n\ta > rect {fill:#0000f0;fill-opacity:0.1;stroke:#0000f0;stroke-width:2}\n\ta {opacity:0}\n\ta:hover {opacity:1}\n\n\tbody {margin:0px}\n\tinput, select {position:absolute;box-sizing:border-box;background:none;border:none;margin:0}\n\tdiv[id] {position:absolute;width:1px;height:1px}\n'

# funkcje
def naLinijki(tekst,x,y,rozmiar):
    wynik=''
    if tekst.count('\n'):
        tekst=tekst.split('\n')
        odgóry=y
        wynik+='>'
        for linia in tekst:
            wynik+='<tspan x="%s" y="%s">%s</tspan>' %(x,odgóry,linia)
            odgóry=round(1.33*rozmiar+odgóry,3)
    else:
        wynik+=' x="%s" y="%s">%s' %(x,y,tekst)
    return wynik

def zsumuj(*liczby):
    wynik=0
    dł=len(liczby)
    if dł==1:
        liczby=liczby[0]
        dł=len(liczby)
    for i in range(dł):
        wynik+=liczby[i]*256**(dł-i-1)
    return wynik

def dajZnać(oCzym):
    print (oCzym,file=stderr)

def lidżbajty(a):
    wynik=''
    for i in a:
        wynik+='%3s ' %i
    return (wynik)

def barwa(r,g,b):
    rgb='#%02x%02x%02x' %(r,g,b)
    if rgb in listaKolorów:
        return listaKolorów[rgb]
    if rgb[1:6:2]==rgb[2:7:2]:
        rgb=rgb[0:7:2]
    return rgb

def przetwórz(dane, ścieżkaWyjścia):
    WSTĘP='<!DOCTYPE html>\n'
    HTML=''
    SVG='<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"'
    łącza=''
    
    tryb='objętość'
    wspólnizna=''
    znaczenieS='jakDługoIPolem'
    listaRozwijek=[]
    zasięgPodmiotów=0
    możliwaRozwijka=False

    if mrucz.count('dobre krótko') or mrucz.count('dobre b. krótko'):
        spisZnaczników=''

    odl=0
    while odl<len(dane):
        daneZ=dane[odl:] # dane znacznika
        bajt=daneZ[0]
        bajty2=zsumuj(daneZ[0:2])
        #    T    B    L    I    S    i    N    M    F    P    C
        if [0x54,0x42,0x4c,0x49,0x53,0x69,0x4e,0x4d,0x46,0x50,0x43].count(bajt):
            możliwaRozwijka=False
            if mrucz.count('dobre'):
                dajZnać('znacznik %s na pozycji %s' %(chr(bajt),odl))
            if mrucz.count('dobre krótko') or mrucz.count('dobre b. krótko'):
                spisZnaczników+=chr(bajt)
        if tryb=='objętość':
            if mrucz.count('objętość'):
                dajZnać('objętość pliku: %s' %(zsumuj(daneZ[0:3])))
            tryb='wersja'
            odl+=2
        elif tryb=='wersja':
            if mrucz.count('wersja'):
                dajZnać('%s' %bajt)
            tryb='wymiary'
        elif tryb=='wymiary':
            SVG+=' width="%s" height="%s">\n' %(bajty2,zsumuj(daneZ[2:5]))
            if mrucz.count('wymiary'):
                dajZnać('wymiary: %s×%s' %(bajty2,zsumuj(daneZ[2:5])))
            odl+=4
            tryb='porcja I'
        elif tryb=='porcja I':
            if mrucz.count('porcja I'):
                dajZnać('porcja I: '+lidżbajty(daneZ[0:5]))
            odl+=4
            tryb='tytuł'
        elif tryb=='tytuł':
            tytuł=daneZ[2:bajty2+2].decode()
            WSTĘP+='<title>%s</title>\n' %tytuł
            if mrucz.count('tytuł'):
                dajZnać('„%s”' %tytuł)
            odl+=bajty2+1
            tryb='ikona'
        elif tryb=='ikona':
            if mrucz.count('ikona'):
                fawikona=open('obrazki/%s.ikona' %nazwaPlikuObml,'wb')
                fawikona.write(daneZ[2:2+bajty2])
                fawikona.close()
                dajZnać('Na %4i bajtów długa ikona'%bajty2)
            tryb='wspólnizna'
            odl+=bajty2+1
        elif tryb=='wspólnizna':
            wspólnizna=daneZ[2:bajty2+2].decode()
            odl+=bajty2+1
            tryb='adres'
        elif tryb=='adres':
            if daneZ[2]==0:
                adres=wspólnizna+daneZ[3:bajty2+2].decode()
            else:
                adres=daneZ[2:bajty2+2].decode()
            WSTĘP+='<link rel=alternate href=%s title="Pierwotna strona" type=text/html>' %adres
            odl+=bajty2+1
            tryb='zaadresie'
        elif tryb=='zaadresie':
            if mrucz.count('zaadresie'):
                dajZnać(str(daneZ[0])+' — '+str(daneZ[1])+' — '+str(zsumuj(daneZ[2:5])))
            odl+=4
            tryb='znaczniki'
        elif tryb=='znaczniki':
            if bajt==0x54: #T
                SVG+='<text'
                styl=''
                rozmiar=17 if daneZ[15]//2%2 else 16 if daneZ[15]//4%2 else 12
                styl+='font-weight:bold;' if daneZ[15]%2 else ''
                styl+='font-size:%spx;' %rozmiar if rozmiar!=12 else ''
                if daneZ[15]>7:
                    dajZnać('formatowanie %s na %s miejscu' %(daneZ[15],odl))
                SVG+=' style="%s"' %styl[:-1] if styl else ''
                SVG+=' opacity="%s"' %round(daneZ[11]/255.0,3) if daneZ[11]<255 else ''
                SVG+=' fill="%s"' %barwa(daneZ[12],daneZ[13],daneZ[14]) if (daneZ[12],daneZ[13],daneZ[14])!=(0,0,0) else ''
                SVG+=naLinijki(daneZ[18:18+zsumuj(daneZ[16:18])].decode(),zsumuj(daneZ[1:3]),zsumuj(daneZ[3:6])+rozmiar,rozmiar)+'</text>\n'
                odl+=18+zsumuj(daneZ[16:18])-1
                if mrucz.count('T'):
                    dajZnać(lidżbajty(daneZ[1:6]))
            elif bajt==0x42: #B
                SVG+='<rect x="%s" y="%s" width="%s" height="%s"' %(zsumuj(daneZ[1:3]),zsumuj(daneZ[3:6]),zsumuj(daneZ[6:8]),zsumuj(daneZ[8:11]))
                SVG+=' opacity="%s"' %round(daneZ[11]/255.0,3) if daneZ[11]/255!=1 else ''
                SVG+=' fill="%s"' %barwa(daneZ[12],daneZ[13],daneZ[14]) if (daneZ[12],daneZ[13],daneZ[14])!=(0,0,0) else ''
                SVG+='/>\n'
                odl+=14
            elif bajt==0x4c: #L
                powtórzeń=daneZ[1]
                if powtórzeń:
                    dPowtórzeń=10*powtórzeń
                    bajtówCelu=zsumuj(daneZ[dPowtórzeń+3:dPowtórzeń+6])
                    łącza+='<a xlink:href="'
                    if daneZ[10*powtórzeń+6]==0:
                        łącza+=wspólnizna+daneZ[dPowtórzeń+7:dPowtórzeń+bajtówCelu+6].decode().replace('&','&amp;')
                    else:
                        łącza+=daneZ[dPowtórzeń+6:dPowtórzeń+bajtówCelu+6].decode().replace('&','&amp;')
                    łącza+='">\n'
                    for i in range(powtórzeń):
                        łącza+='\t<rect x="%s" y="%s" width="%s" height="%s"/>\n' %(zsumuj(daneZ[10*i+2:10*i+4]),zsumuj(daneZ[10*i+4:10*i+7]),zsumuj(daneZ[10*i+7:10*i+9]),zsumuj(daneZ[10*i+9:10*i+12]))
                    łącza+='</a>\n'
                    odl+=dPowtórzeń+bajtówCelu+5
                else:
                    odl+=9
            elif bajt==0x49: #I
                if odl<zasięgPodmiotów:
                    #powtórzeń=bajt
                    bajtówCelu=zsumuj(daneZ[12:14])
                    #HTML+='<input type="%s" style="left:%spx;top:%spx;width:%spx;height:%spx;"/>\n' %('',zsumuj(daneZ[2:4]),zsumuj(daneZ[4:7]),zsumuj(daneZ[7:9]),zsumuj(daneZ[9:12]))
                    #if mrucz.count('I'):
                        #dajZnać('I: '+lidżbajty(daneZ[:19]))
                    odl+=18+bajtówCelu
                else:
                    SVG+='<rect transform="translate(%s,%s)" width="%s" height="%s" style="background-color:%s" fill="url(#wyp%s)"/>\n' %(zsumuj(daneZ[1:3]),zsumuj(daneZ[3:6]),zsumuj(daneZ[6:8]),zsumuj(daneZ[8:11]),barwa(daneZ[12],daneZ[13],daneZ[14]),zsumuj(daneZ[18:21]))
                    odl+=20
            elif bajt==0x53: #S
                if znaczenieS=='jakDługoIPolem':
                    zasięgPodmiotów=odl+zsumuj(daneZ[1:4])
                    if mrucz.count('pierwszy S'):
                        dajZnać(lidżbajty(daneZ[1:4]))
                    znaczenieS='plecak, guziki'
                    możliwaRozwijka=True
                    odl+=3
                elif znaczenieS=='plecak, guziki' and odl<zasięgPodmiotów:
                    powtórzeń=daneZ[1]
                    dPowtórzeń=powtórzeń*10
                    bajtówCelu=daneZ[dPowtórzeń+5]
                    nazwa=daneZ[dPowtórzeń+6:dPowtórzeń+bajtówCelu+6].decode()
                    if powtórzeń:
                        for i in range(0,dPowtórzeń,10):
                            HTML+='<input type=submit style="left:%spx;top:%spx;width:%spx;height:%spx;" value="">\n' %(zsumuj(daneZ[i+2:i+4]),zsumuj(daneZ[i+4:i+7]),zsumuj(daneZ[i+7:i+9]),zsumuj(daneZ[i+9:i+12]))
                    odl+=dPowtórzeń+bajtówCelu+5
                elif znaczenieS=='plecak, guziki' and odl>=zasięgPodmiotów:
                    rozmiarPlecaka=zsumuj(daneZ[1:4])
                    if mrucz.count('zaadresie'):
                        dajZnać(rozmiarPlecaka)
                    stemple=daneZ[4:4+rozmiarPlecaka]
                    nr=0
                    while nr<rozmiarPlecaka:
                        długośćStempla=zsumuj(stemple[nr:nr+2])
                        stempel=stemple[nr+2:nr+długośćStempla+2]
                        nibystempel=b64encode(stempel).decode()
                        mime='image/png' if nibystempel[0:2]=='iV' else 'image/jpeg' if nibystempel[0:2]=='/9' else ''
                        if mime=='image/png':
                            ihdr=stempel.find(b'IHDR')
                            szerokość=zsumuj(stempel[ihdr+4:ihdr+8])
                            wysokość=zsumuj(stempel[ihdr+8:ihdr+12])
                        elif mime=='image/jpeg':
                            szerokość=stempel[166]
                            wysokość=stempel[164]
                        SVG+='<pattern width="%s" height="%s" patternUnits="userSpaceOnUse" id="wyp%s">\n' %(szerokość,wysokość,nr)
                        SVG+='\t<image x="0" y="0" width="%s" height="%s" xlink:href="data:%s;base64,%s"/>\n' %(szerokość,wysokość,mime,nibystempel)
                        SVG+='</pattern>\n'
                        if mrucz.count('obrazki'):
                            plik=open('obrazki/%s-%s.%s' %(nazwaPlikuObml[:-5],nr,mime[6:]),'wb')
                            plik.write(stempel)
                            plik.close()
                        nr+=2+długośćStempla
                    odl+=3+rozmiarPlecaka
            elif bajt==0x69: #i
                dPowtórzeń=10*daneZ[1]
                bajtówMime=zsumuj(daneZ[dPowtórzeń+2:dPowtórzeń+4])
                bajtówAdresu=zsumuj(daneZ[dPowtórzeń+bajtówMime+4:dPowtórzeń+bajtówMime+6])
                odl+=dPowtórzeń+bajtówMime+bajtówAdresu+5
            elif bajt==0x4e: #N
                powtórzeń=daneZ[1]
                dPowtórzeń=powtórzeń*10
                bajtówCelu=zsumuj(daneZ[dPowtórzeń+11:dPowtórzeń+13])
                nazwa=daneZ[dPowtórzeń+13:dPowtórzeń+bajtówCelu+13].decode()
                if powtórzeń:
                    łącza+='<a xlink:href="#'
                    łącza+=nazwa
                    łącza+='">\n'
                    for i in range(0,dPowtórzeń,10):
                        łącza+='\t<rect x="%s" y="%s" width="%s" height="%s"/>\n' %(zsumuj(daneZ[i+2:i+4]),zsumuj(daneZ[i+4:i+7]),zsumuj(daneZ[i+7:i+9]),zsumuj(daneZ[i+9:i+12]))
                    łącza+='</a>\n'
                HTML+='<div id="%s" style="left:%spx;top:%spx;"></div>\n' %(nazwa,zsumuj(daneZ[6+dPowtórzeń:8+dPowtórzeń]),zsumuj(daneZ[8+dPowtórzeń:11+dPowtórzeń]))
                odl+=dPowtórzeń+bajtówCelu+12
            elif bajt==0x4d: #M
                if daneZ[1]==0x43: #C
                    if mrucz.count('MC'):
                        dajZnać('\t'+lidżbajty(daneZ[2:5+zsumuj(daneZ[2:5])]))
                    odl+=4+zsumuj(daneZ[2:5])
                elif daneZ[1]==0x75: #u
                    if mrucz.count('Mu'):
                        dajZnać(lidżbajty(daneZ[2:9]))
                    odl+=8
                elif daneZ[1]==0x54: #T
                    odl+=4+zsumuj(daneZ[2:5])
                    if mrucz.count('MT'):
                        wynik=''
                        for i in daneZ[5:5+zsumuj(daneZ[2:5])]:wynik+='%x '%i
                        dajZnać(wynik)
                elif daneZ[1]==0x53: #S
                    """informacje o certyfikacie, bezpieczeństwie strony"""
                    bajtówCelu=zsumuj(daneZ[2:5])
                    if mrucz.count('certyfikat'):
                        minione=5
                        for informacja in ['Właściciel','Organizacja','Wystawca','Wygasa','Gadka','Protokół','Domena']:
                            bajtówPodcelu=zsumuj(daneZ[minione:minione+2])
                            minione+=2
                            dajZnać(informacja+': '+daneZ[minione:minione+bajtówPodcelu].decode())
                            minione+=bajtówPodcelu
                    odl+=bajtówCelu+4
            elif bajt==0x46: #F
                bajtówCelu=zsumuj(daneZ[17:19])
                bajtów2Celu=zsumuj(daneZ[19+bajtówCelu:21+bajtówCelu])
                rodzaj=rodzajePól[daneZ[15]][0]
                podrodzaj='type=%s ' %rodzajePól[daneZ[15]][1] if rodzajePól[daneZ[15]][1] else ''
                kolor='color:%s' %barwa(daneZ[12],daneZ[13],daneZ[14]) if (daneZ[12],daneZ[13],daneZ[14])!=(0,0,0) else ''
                krycie='opacity:%s;' %round(daneZ[11]/255.0,3) if daneZ[11]/255!=1 else ''
                if rodzajePól[daneZ[15]][0]=='input':
                    zakończenie='>'
                elif rodzajePól[daneZ[15]][0]=='textarea':
                    zakończenie='></textarea>'
                elif rodzajePól[daneZ[15]][0]=='select':
                    zakończenie='>'
                    for i in listaRozwijek.pop(0):
                        zakończenie+='<option>%s</option>' %i
                    zakończenie+='</select>'
                poprawki=poprawkiPól[rodzaj]
                HTML+='<%s %sstyle="left:%spx;top:%spx;width:%spx;height:%spx;%s%s"%s\n' %(rodzaj,podrodzaj,zsumuj(daneZ[1:3])-poprawki[0],zsumuj(daneZ[3:6])-poprawki[0],zsumuj(daneZ[6:8])+poprawki[1],zsumuj(daneZ[8:11])+poprawki[2],kolor,krycie,zakończenie)
                if mrucz.count('F'):
                    dajZnać(lidżbajty(daneZ[:18+bajtówCelu+2+bajtów2Celu+3+2]))
                if mrucz.count('F²'):
                    daneZ[19+bajtówCelu:21+bajtówCelu]
                odl+=bajtówCelu+bajtów2Celu+23
            elif bajt==0x50: #P
                dPowtórzeń=daneZ[1]*10
                bajtówCelu=zsumuj(daneZ[dPowtórzeń+4:dPowtórzeń+6])
                odl+=dPowtórzeń+bajtówCelu+5
            elif bajt==0x43: #C
                odl+=21
            elif bajt==0x00 and możliwaRozwijka:
                liczbaPozycji=zsumuj(daneZ[1:3])
                odl+=3
                rozwijka=[]
                for i in range(liczbaPozycji):
                    daneZ=dane[odl:]
                    długośćNumeru=zsumuj(daneZ[0:2])
                    numer=daneZ[2:długośćNumeru+2]
                    długośćWyrażenia=zsumuj(daneZ[długośćNumeru+2:długośćNumeru+4])
                    wyrażenie=daneZ[długośćNumeru+4:długośćNumeru+4+długośćWyrażenia].decode()
                    odl+=długośćNumeru+4+długośćWyrażenia
                    rozwijka.append(wyrażenie)
                listaRozwijek.append(rozwijka)
                odl-=1
            else:
                if mrucz.count('złe'):
                    dajZnać('%s 0x%02x — nieprawidłowy znak' %(odl,bajt))
                quit()
        else:
            dajZnać('coś tu nie gra: %s' %odl)
            break
        odl+=1
    SVG+=łącza
    SVG+='</svg>\n'
    
    if mrucz.count('dobre b. krótko'):
        b=' '
        for i in spisZnaczników:
            if i!=b[-1]:
                    b+=i
        spisZnaczników=b[1:]
    
    if mrucz.count('dobre krótko') or mrucz.count('dobre b. krótko'):
        dajZnać(spisZnaczników)
    
    if svgz!='nie':
        tymczasowy=open('obml_svg.tpm','w')
        tymczasowy.write(SVG.replace('</svg>','<style>%s</style>\n</svg>' %CSS))
        tymczasowy.close()
        
        os.system('cat obml_svg.tpm | gzip > obml_svg.2.tpm')
        os.system('base64 -w 0 obml_svg.2.tpm > obml_svg.tpm')
        
        tymczasowy=open('obml_svg.tpm','r')
        zbasowany=tymczasowy.read()
        tymczasowy.close()
        
        os.system('rm obml_svg.tpm obml_svg.2.tpm')
        
        zbasowany='<img src="data:image/svg+xml;base64,%s"/>' %zbasowany
        
        if svgz=='tak' or ( svgz=='mniejsze' and len(zbasowany)<len(SVG) ) or ( svgz=='większe' and len(zbasowany)>len(SVG) ):
            SVG=zbasowany
    
    wyjście=open(ścieżkaWyjścia,'w')
    print (WSTĘP,file=wyjście)
    print ('<style>\n%s</style>' %CSS,file=wyjście)
    print (SVG,file=wyjście)
    print (HTML,file=wyjście)
    wyjście.close()

if len(argv)==1:
    print ("Nie podano pliku", file=stderr)
    quit()
for nazwaPlikuObml in argv[1:]:
    if mrucz.count('plik'):
        dajZnać('\n'+nazwaPlikuObml)
    
    try:
        plikObml=open(nazwaPlikuObml,'rb')
    except IOError:
        print ("Nie ma takiego pliku", file=stderr)
        continue
    
    dane=plikObml.read()
    plikObml.close()
    przetwórz(dane,nazwaPlikuObml[:-4]+'html')
