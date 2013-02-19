###
    python.coffee
###
int = (a) -> parseInt a
chr = (a) -> String.fromCharCode a
str = (a) -> String a
len = (a) -> a.length
ord = (a) -> a.charCodeAt 0
Array::append = (a) -> @push a
Array::count = (a) ->
    wynik = 0
    for i in [0 .. @length-1]
        if this[i]==a
            wynik+=1
    wynik
Array::decode = -> listaWNapis @
listaWNapis = (lista) ->
    napis = ''
    j = 0
    while j < lista.length
        i = lista[j]
        if i > 127
            for k, l in [0, 0, 192, 224, 240, 248, 252].reverse()
                l = 5-l
                if i >= k
                    i -= k
                    mnożnik = Math.pow 64, l
                    i *= mnożnik
                    for m in [1 .. l]
                        mnożnik /= 64
                        i += (lista[j+m]-128) * mnożnik
                    j += l
                    break
        napis += String.fromCharCode i
        ++j
    napis

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

b64encodeW1=(a)->
    wynik='_'
    cyfry='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    ogon=''
    if 'string'==typeof a
        a=napisWListę a
    while a.length
        plastry=[0,0,0,0,0,0]
        b=a[..2]
        a=a[3..]
        if b.length==3
            plastry[1]=b[0]%4
            plastry[0]=(b[0]-plastry[1])/4
            plastry[3]=b[1]%16
            plastry[2]=(b[1]-plastry[3])/16
            plastry[5]=b[2]%64
            plastry[4]=(b[2]-plastry[5])/64
            t_base=[plastry[0],plastry[1]*16+plastry[2],plastry[3]*4+plastry[4],plastry[5]]
        else if b.length==2
            plastry[1]=b[0]%4
            plastry[0]=(b[0]-plastry[1])/4
            plastry[3]=b[1]%16
            plastry[2]=(b[1]-plastry[3])/16
            t_base=[plastry[0],plastry[1]*16+plastry[2],plastry[3]*4]
            ogon='='
        else if b.length==1
            plastry[1]=b[0]%4
            plastry[0]=(b[0]-plastry[1])/4
            t_base=[plastry[0],plastry[1]*16]
            ogon='=='
        for i in [0 .. t_base.length-1]
            wynik+=cyfry[t_base[i]]
    wynik[1..]+ogon

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

# Math.round = (liczba, miejsca, typ) ->
#     typ=typ or 0
#     liczba=str(liczba).replace '.', ','
#     mnóż=(napis, liczba) ->
#         wynik=''
#         for i in [1 .. liczba] by 1
#             wynik+=napis
#         wynik
#     if liczba.match ','
#         liczba+=mnóż '0', miejsca-(liczba.length-liczba.indexOf(',')-1)
#     else
#         liczba+=','+((mnóż '0', miejsca) or '0')
#     liczba[..(liczba.length-liczba.indexOf ',')+miejsca-2]

True=true
False=false

###
    część właściwa
###
Array::find = (a) ->
    if 'string'==typeof a
        a=napisWListę a
    for i in [0 .. @length-a.length]
        if @[i]==a[0]
            licznik=1
            for j, k in a[1 ..]
                if @[i+k+1]==j
                    ++licznik
            if licznik==a.length
                return i
    -1

$ = (a) ->
    document.getElementById a
($ 'wejście').onchange = (zd) ->
    for plik in zd.target.files
        plikoobrabiacz = new FileReader()
        plikoobrabiacz.onload = (zd) ->
            nazwaPlikuObml='cokolwiek.obml'
            if mrucz.count('plik')
                dajZnać('\n'+nazwaPlikuObml)
            ($ 'narysowane').innerHTML=przetwórz (i for i in zd.target.result), 'a.html'
        plikoobrabiacz.readAsArrayBuffer plik

# ustawienia
svgz='nie' # nie, większe, mniejsze, tak, wg pogody

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
    #'porcja_I',
    'plik',
    'objętość',
    #'porcja_II',
    #'tytuł',
    'porcja_III',
    #'Mu',
    #'MC',
    #'T',
    #'obrazki',
    'certyfikat',
]
# „stałe”
rodzajePól=
    97  : ['textarea',false],
    99  : ['input','checkbox'],
    112 : ['input','password'],
    114 : ['input','radio'],
    115 : ['select',false],
    120 : ['input','text']

poprawkiPól={'input':[2,6,6],'select':[0,18,0],'textarea':[0,0,0]}
listaKolorów={'#c0c0c0':'silver','#808080':'gray','#800000':'maroon','#ff0000':'red','#800080':'purple','#008000':'green','#808000':'olive','#000080':'navy','#008080':'teal','#f0ffff':'azure','#f5f5dc':'beige','#ffe4c4':'bisque','#a52a2a':'brown','#ff7f50':'coral','#ffd700':'gold','#4b0082':'indigo','#fffff0':'ivory','#f0e68c':'khaki','#faf0e6':'linen','#da70d6':'orchid','#cd853f':'peru','#ffc0cb':'pink','#dda0dd':'plum','#fa8072':'salmon','#a0522d':'sienna','#fffafa':'snow','#d2b48c':'tan','#ff6347':'tomato','#ee82ee':'violet','#f5deb3':'wheat'}
CSS='\ttext {font-size:12px;font-family:sans-serif}\n\ta > rect {fill:#0000f0;fill-opacity:0.1;stroke:#0000f0;stroke-width:2}\n\tsvg a {opacity:0}\n\tsvg a:hover {opacity:1}\n\n\tbody {margin:0px}\n\tsvg + input, svg + select {position:absolute;box-sizing:border-box;background:none;border:none;margin:0}\n\tsvg + div[id] {position:absolute;width:1px;height:1px}\n'

# funkcje
naLinijki = (tekst,x,y,rozmiar) ->
    wynik=''
    tekst=unescape tekst
    if tekst.match('\n')
        tekst=tekst.split('\n')
        odgóry=y
        wynik+='>'
        for linia in tekst
            wynik+="<tspan x='#{x}' y='#{odgóry}'>#{linia}</tspan>"
            odgóry=1.33*rozmiar+odgóry # NAPRAWIĆ Math.round 
    else
        wynik+=" x='#{x}' y='#{y}'>#{tekst}"
    return wynik

zsumuj = (liczby...) ->
    wynik=0
    dł=liczby.length
    if dł==1
        liczby=liczby[0]
        dł=liczby.length
    for i in [0 .. dł-1]
        wynik+=liczby[i]*Math.pow 256, dł-i-1
    wynik

dajZnać = (oCzym) ->
    console.log (oCzym)

lidżbajty = (a) ->
    wynik=''
    for i in a
        wynik+="#{i} "
    return (wynik)

barwa = (r,g,b) ->
    _16 = (a,dł) ->
        w=''
        while a>0
            w='0123456789abcdef'[a%16]+w
            a=int a/16
        while dł>w.length
            w='0'+w
        w
    rgb='#'+(_16 r,2)+(_16 g,2)+(_16 b,2)
    if listaKolorów[rgb] then rgb=listaKolorów[rgb]
    else if rgb[1]+rgb[3]+rgb[5]==rgb[2]+rgb[4]+rgb[6] then rgb=rgb[0 .. 1]+rgb[4 .. 5]
    rgb

przetwórz = (dane, ścieżkaWyjścia) ->
    WSTĘP='<!DOCTYPE html>\n'
    HTML=''
    SVG='<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"'
    łącza=''

    tryb='objętość'
    wspólnizna=''
    znaczenieS='jakDługoIPolem'
    listaRozwijek=[]
    zasięgPodmiotów=0
    możliwaRozwijka=false

    if mrucz.count('dobre krótko') or mrucz.count('dobre b. krótko')
        spisZnaczników=''

    odl=0
    while odl<dane.length
        daneZ=dane[odl ..] # dane znacznika
        bajt=daneZ[0]
        bajty2=zsumuj(daneZ[0 .. 1])
        #    T    B    L    I    S    i    N    M    F    P    C
        if [0x54,0x42,0x4c,0x49,0x53,0x69,0x4e,0x4d,0x46,0x50,0x43].count(bajt)
            możliwaRozwijka=false
            if mrucz.count('dobre')
                dajZnać("znacznik #{chr(bajt)} na pozycji #{odl}")
            if mrucz.count('dobre krótko') or mrucz.count('dobre b. krótko')
                spisZnaczników+=chr(bajt)
        if tryb=='objętość'
            if mrucz.count('objętość')
                dajZnać('objętość pliku: ' + zsumuj(daneZ[0 .. 2]) )
            tryb='wersja'
            odl+=2
        else if tryb=='wersja'
            if mrucz.count('wersja')
                dajZnać(bajt)
            tryb='wymiary'
        else if tryb=='wymiary'
            SVG+=" width='#{bajty2}' height='#{zsumuj(daneZ[2 .. 4])}'>\n"
            if mrucz.count('wymiary')
                dajZnać("wymiary: #{bajty2}×#{zsumuj(daneZ[2 .. 4])}")
            odl+=4
            tryb='porcja_I'
        else if tryb=='porcja_I'
            if mrucz.count('porcja_I')
                dajZnać('porcja_I: '+lidżbajty(daneZ[0 .. 4]))
            odl+=4
            tryb='tytuł'
        else if tryb=='tytuł'
            tytuł=daneZ[2 .. bajty2+1].decode()
            WSTĘP+="<title>#{tytuł}</title>\n"
            if mrucz.count('tytuł')
                dajZnać("„#{tytuł}”")
            odl+=bajty2+1
            tryb='porcja_II'
        else if tryb=='porcja_II'
            if mrucz.count('porcja_II')
                dajZnać(daneZ[2:2+bajty2])
            tryb='wspólnizna'
            odl+=bajty2+1
        else if tryb=='wspólnizna'
            wspólnizna=daneZ[2 .. bajty2+1].decode()
            odl+=bajty2+1
            tryb='adres'
        else if tryb=='adres'
            if daneZ[2]==0
                adres=wspólnizna+daneZ[3  ..bajty2+1].decode()
            else
                adres=daneZ[2 .. bajty2+1].decode()
            WSTĘP+="<link rel=alternate href=#{adres} title='Pierwotna strona' type=text/html>"
            odl+=bajty2+1
            tryb='porcja_III'
        else if tryb=='porcja_III'
            if mrucz.count('porcja_III')
                dajZnać(str(daneZ[0])+' — '+str(daneZ[1])+' — '+str(zsumuj(daneZ[2..4])))
            odl+=4
            tryb='znaczniki'
        else if tryb=='znaczniki'
            if bajt==0x54 #T
                SVG+='<text'
                styl=''
                rozmiar = if int(daneZ[15]/2)%2 then 17 else if int(daneZ[15]/4)%2 then 16 else 12
                styl+=if daneZ[15]%2 then 'font-weight:bold;' else ''
                styl+=if rozmiar!=12 then "font-size:#{rozmiar}px;" else ''
                if daneZ[15]>7
                    dajZnać("formatowanie #{daneZ[15]} na #{odl} miejscu")
                SVG+=if styl then " style='#{styl}'" else ''
                SVG+=if daneZ[11]<255 then " opacity='#{daneZ[11]/255.0}'" else ''
                SVG+=if not (daneZ[12]==daneZ[13]==daneZ[14]==0) then " fill='#{barwa(daneZ[12],daneZ[13],daneZ[14])}'" else ''
                SVG+=naLinijki(daneZ[18 .. 17+zsumuj(daneZ[16 .. 17])].decode(),zsumuj(daneZ[1 .. 2]),zsumuj(daneZ[3 .. 5])+rozmiar,rozmiar)+'</text>\n'
                odl+=18+zsumuj(daneZ[16 .. 17])-1
                if mrucz.count('T')
                    dajZnać(lidżbajty(daneZ[1 .. 5]))
            else if bajt==0x42 #B
                SVG+="<rect x='#{zsumuj(daneZ[1 .. 2])}' y='#{zsumuj(daneZ[3 .. 5])}' width='#{zsumuj(daneZ[6 .. 7])}' height='#{zsumuj(daneZ[8 .. 10])}'"
                SVG+=if daneZ[11]/255!=1 then " opacity='#{daneZ[11]/255}'" else '' #'
                SVG+=if not (daneZ[12]==daneZ[13]==daneZ[14]==0) then " fill='#{barwa(daneZ[12],daneZ[13],daneZ[14])}'" else ''
                SVG+='/>\n'
                odl+=14
            else if bajt==0x4c #L
                powtórzeń=daneZ[1]
                if powtórzeń
                    dPowtórzeń=10*powtórzeń
                    bajtówCelu=zsumuj(daneZ[dPowtórzeń+3 .. dPowtórzeń+5])
                    łącza+='<a xlink:href="'
                    if daneZ[10*powtórzeń+6]==0
                        łącza+=wspólnizna+daneZ[dPowtórzeń+7 .. dPowtórzeń+bajtówCelu+5].decode().replace('&','&amp;')
                    else
                        łącza+=daneZ[dPowtórzeń+6 .. dPowtórzeń+bajtówCelu+5].decode().replace('&','&amp;')
                    łącza+='">\n'
                    for i in [0 .. powtórzeń-1]
                        łącza+="\t<rect x='#{zsumuj(daneZ[10*i+2 .. 10*i+3])}' y='#{zsumuj(daneZ[10*i+4 .. 10*i+6])}' width='#{zsumuj(daneZ[10*i+7 .. 10*i+8])}' height='#{zsumuj(daneZ[10*i+9 .. 10*i+11])}'/>\n"
                    łącza+='</a>\n'
                    odl+=dPowtórzeń+bajtówCelu+5
                else
                    odl+=9
            else if bajt==0x49 #I
                if odl<zasięgPodmiotów
                    #powtórzeń=bajt
                    bajtówCelu=zsumuj(daneZ[12 .. 13])
                    #HTML+='<input type="%s" style="left:%spx;top:%spx;width:%spx;height:%spx;"/>\n' %('',zsumuj(daneZ[2:4]),zsumuj(daneZ[4:7]),zsumuj(daneZ[7:9]),zsumuj(daneZ[9:12]))
                    #if mrucz.count('I'):
                        #dajZnać('I: '+lidżbajty(daneZ[:19]))
                    odl+=18+bajtówCelu
                else
                    SVG+="<rect transform='translate(#{zsumuj(daneZ[1 .. 2])},#{zsumuj(daneZ[3 .. 5])})' width='#{zsumuj(daneZ[6 .. 7])}' height='#{zsumuj(daneZ[8 .. 10])}' style='background-color:#{barwa(daneZ[12],daneZ[13],daneZ[14])}' fill='url(#wyp#{zsumuj(daneZ[18 .. 20])})'/>\n"
                    odl+=20
            else if bajt==0x53 #S
                if znaczenieS=='jakDługoIPolem'
                    zasięgPodmiotów=odl+zsumuj(daneZ[1 .. 3])
                    if mrucz.count('pierwszy S')
                        dajZnać(lidżbajty(daneZ[1 .. 3]))
                    znaczenieS='plecak, guziki'
                    możliwaRozwijka=true
                    odl+=3
                else if znaczenieS=='plecak, guziki' and odl<zasięgPodmiotów
                    powtórzeń=daneZ[1]
                    dPowtórzeń=powtórzeń*10
                    bajtówCelu=daneZ[dPowtórzeń+5]
                    nazwa=daneZ[dPowtórzeń+6 .. dPowtórzeń+bajtówCelu+5].decode()
                    if powtórzeń
                        for i in [0 .. dPowtórzeń-1] by 10
                            HTML+="<input type=submit style='left:#{zsumuj(daneZ[i+2 .. i+3])}px;top:#{zsumuj(daneZ[i+4 .. i+6])}px;width:#{zsumuj(daneZ[i+7 .. i+8])}px;height:#{zsumuj(daneZ[i+9 .. i+11])}px;' value=''>\n"
                    odl+=dPowtórzeń+bajtówCelu+5
                else if znaczenieS=='plecak, guziki' and odl>=zasięgPodmiotów
                    rozmiarPlecaka=zsumuj(daneZ[1 .. 3])
                    if mrucz.count('porcja_III')
                        dajZnać(rozmiarPlecaka)
                    stemple=daneZ[4 .. rozmiarPlecaka+3]
                    nr=0
                    while nr<rozmiarPlecaka
                        długośćStempla=zsumuj(stemple[nr .. nr+1])
                        stempel=stemple[nr+2 .. nr+długośćStempla+1]
                        nibystempel=b64encode(stempel)
                        mime=if nibystempel[0 .. 1]=='iV' then 'image/png' else if nibystempel[0 .. 1]=='/9' then 'image/jpeg' else ''
                        if mime=='image/png'
                            ihdr=stempel.find('IHDR')
                            szerokość=zsumuj(stempel[ihdr+4 .. ihdr+7])
                            wysokość=zsumuj(stempel[ihdr+8 .. ihdr+11])
                        else if mime=='image/jpeg'
                            szerokość=stempel[166]
                            wysokość=stempel[164]
                        SVG+="<pattern width='#{szerokość}' height='#{wysokość}' patternUnits='userSpaceOnUse' id='wyp#{nr}'>\n"
                        SVG+="\t<image x='0' y='0' width='#{szerokość}' height='#{wysokość}' xlink:href='data:#{mime};base64,#{nibystempel}'/>\n"
                        SVG+='</pattern>\n'

                        ###
                        if mrucz.count('obrazki')
                            plik=open("obrazki/#{nazwaPlikuObml[:-5]}-#{nr}.#{mime[6:]}",'wb')
                            plik.write(stempel)
                            plik.close()
                        ###

                        nr+=2+długośćStempla
                    odl+=3+rozmiarPlecaka
            else if bajt==0x69 #i
                dPowtórzeń=10*daneZ[1]
                bajtówMime=zsumuj(daneZ[dPowtórzeń+2 .. dPowtórzeń+3])
                bajtówAdresu=zsumuj(daneZ[dPowtórzeń+bajtówMime+4 .. dPowtórzeń+bajtówMime+5])
                odl+=dPowtórzeń+bajtówMime+bajtówAdresu+5
            else if bajt==0x4e #N
                powtórzeń=daneZ[1]
                dPowtórzeń=powtórzeń*10
                bajtówCelu=zsumuj(daneZ[dPowtórzeń+11 .. dPowtórzeń+12])
                nazwa=daneZ[dPowtórzeń+13 .. dPowtórzeń+bajtówCelu+12].decode()
                if powtórzeń
                    łącza+='<a xlink:href="#'
                    łącza+=nazwa
                    łącza+='">\n'
                    for i in [0 .. dPowtórzeń-1] by 10
                        łącza+="\t<rect x='#{zsumuj(daneZ[i+2 .. i+3])}' y='#{zsumuj(daneZ[i+4 .. i+6])}' width='#{zsumuj(daneZ[i+7 .. i+8])}' height='#{zsumuj(daneZ[i+9 .. i+11])}'/>\n"
                    łącza+='</a>\n'
                HTML+="<div id='#{nazwa}' style='left:#{zsumuj(daneZ[6+dPowtórzeń .. 8+dPowtórzeń])}px;top:#{zsumuj(daneZ[8+dPowtórzeń .. 11+dPowtórzeń])}px;'></div>\n"
                odl+=dPowtórzeń+bajtówCelu+12
            else if bajt==0x4d #M
                if daneZ[1]==0x43 #C
                    if mrucz.count('MC')
                        dajZnać('\t'+lidżbajty(daneZ[2 .. zsumuj(daneZ[2 .. 4])+4]))
                    odl+=4+zsumuj(daneZ[2 .. 4])
                else if daneZ[1]==0x75 #u
                    if mrucz.count('Mu')
                        dajZnać(lidżbajty(daneZ[2 .. 8]))
                    odl+=8
                else if daneZ[1]==0x54 #T
                    odl+=4+zsumuj(daneZ[2 .. 4])
                    if mrucz.count('MT')
                        wynik=''
                        for i in daneZ[5 .. zsumuj(daneZ[2 .. 4])+4]
                            wynik+=i+' '
                        dajZnać(wynik)
                else if daneZ[1]==0x53 #S
                    ###informacje o certyfikacie, bezpieczeństwie strony###
                    bajtówCelu=zsumuj(daneZ[2 .. 4])
                    if mrucz.count('certyfikat')
                        minione=5
                        for informacja in ['Właściciel','Organizacja','Wystawca','Wygasa','Gadka','Protokół','Domena']
                            bajtówPodcelu=zsumuj(daneZ[minione .. minione+1])
                            minione+=2
                            dajZnać(informacja+': '+daneZ[minione .. minione+bajtówPodcelu-1].decode())
                            minione+=bajtówPodcelu
                    odl+=bajtówCelu+4
            else if bajt==0x46 #F
                bajtówCelu=zsumuj(daneZ[17 .. 18])
                bajtów2Celu=zsumuj(daneZ[19+bajtówCelu .. 20+bajtówCelu])
                rodzaj=rodzajePól[daneZ[15]][0]
                podrodzaj="type=#{if rodzajePól[daneZ[15]][1] then rodzajePól[daneZ[15]][1] else ''} "
                kolor=if not daneZ[12]==daneZ[13]==daneZ[14]==0 then "color:#{barwa(daneZ[12],daneZ[13],daneZ[14])}" else ''
                krycie=if daneZ[11]/255!=1 then "opacity:#{daneZ[11]/255};"  else '' #"
                if rodzajePól[daneZ[15]][0]=='input'
                    zakończenie='>'
                else if rodzajePól[daneZ[15]][0]=='textarea'
                    zakończenie='></textarea>'
                else if rodzajePól[daneZ[15]][0]=='select'
                    zakończenie='>'
                    for i in listaRozwijek.pop(0)
                        zakończenie+="<option>#{i}</option>"
                    zakończenie+='</select>'
                poprawki=poprawkiPól[rodzaj]
                HTML+="<#{rodzaj} #{podrodzaj}style='left:#{zsumuj(daneZ[1 .. 2])-poprawki[0]}px;top:#{zsumuj(daneZ[3 .. 5])-poprawki[0]}px;width:#{zsumuj(daneZ[6 .. 7])+poprawki[1]}px;height:#{zsumuj(daneZ[8 .. 10])+poprawki[2]}px;#{kolor}#{krycie}'#{zakończenie}\n"
                if mrucz.count('F')
                    dajZnać(lidżbajty(daneZ[.. 18+bajtówCelu+2+bajtów2Celu+3+2-1]))
                if mrucz.count('F²')
                    daneZ[19+bajtówCelu .. 20+bajtówCelu]
                odl+=bajtówCelu+bajtów2Celu+23
            else if bajt==0x50 #P
                dPowtórzeń=daneZ[1]*10
                bajtówCelu=zsumuj(daneZ[dPowtórzeń+4 .. dPowtórzeń+5])
                odl+=dPowtórzeń+bajtówCelu+5
            else if bajt==0x43 #C
                odl+=21
            else if bajt==0x00 and możliwaRozwijka
                liczbaPozycji=zsumuj(daneZ[1 .. 2])
                odl+=3
                rozwijka=[]
                for i in [0 .. liczbaPozycji-1]
                    daneZ=dane[odl .. ]
                    długośćNumeru=zsumuj(daneZ[0 .. 1])
                    numer=daneZ[2 .. długośćNumeru+1]
                    długośćWyrażenia=zsumuj(daneZ[długośćNumeru+2 .. długośćNumeru+3])
                    wyrażenie=daneZ[długośćNumeru+4 .. długośćNumeru+3+długośćWyrażenia].decode()
                    odl+=długośćNumeru+4+długośćWyrażenia
                    rozwijka.append(wyrażenie)
                listaRozwijek.append(rozwijka)
                odl-=1
            else
                if mrucz.count('złe')
                    dajZnać("#{odl} #{bajt} — nieprawidłowy znak")
                quit()
        else
            dajZnać('coś tu nie gra: '+odl)
            break
        odl+=1
    SVG+=łącza
    SVG+='</svg>\n'

    if mrucz.count('dobre b. krótko')
        b=' '
        for i in spisZnaczników
            if i!=b[b.length-1]
                    b+=i
        spisZnaczników=b[1 ..]

    if mrucz.count('dobre krótko') or mrucz.count('dobre b. krótko')
        dajZnać(spisZnaczników)

    ###
    if svgz!='nie'
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

        if svgz=='tak' or ( svgz=='mniejsze' and len(zbasowany)<len(SVG) ) or ( svgz=='większe' and len(zbasowany)>len(SVG) )
            SVG=zbasowany
    ###

    wyjście=''
    #wyjście+=WSTĘP
    wyjście+="<style>\n#{CSS}</style>"
    wyjście+=SVG
    wyjście+=HTML
    wyjście=wyjście
    wyjście
