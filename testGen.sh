#!/bin/bash

#Author: @peppelischio
#blablablabalblaba random tests generator

if [ -e /autogenTests ]; then #creazione della cartella con check su esistenza pregressa
  mkdir autogenTests
fi

#creazione del file prendendo in input il nome quando runno lo script
if [ ! -e $1 ]; then
  echo >> autogenTests/$1
fi


for testCases in {1..5000}
  do
    #qui ci piazzo tutta la logica di creazione di un caso di test
    declare -a lista=() #creazione lista vuota

    i=0
    while [ $i -lt 8 ] #popolo la lista con valori random
      do
        toInsert=$(expr $RANDOM % 127)
        if [ $i -eq 0 ]; then #il primo valore viene inserito senza check
          lista+=($toInsert)
          #lista+=(7)
          i=$(($i + 1))
        else
         #caso in cui non è il primo valore che inserisco
          #faccio qui il check sulla distanza (con un while): se è lecita fino
          #all'ultima iterazione allora inserisco il valore. altrimenti esco dal
          #while interno e procedo a fare un check su un nuovo valore generato
          j=0
          while [ $j -lt $i ]
            do
            firstEvaluation=$(( ${lista[$j]} - $toInsert ))
            secondEvaluation=$(( $toInsert - ${lista[$j]} ))
              if [[ $firstEvaluation -gt 3 || $secondEvaluation -gt 3 ]]; then #caso in cui il valore da inserire è lecito
                j=$(($j + 1))
              else ##caso in cui c'è overlapping
                toInsert=$(expr $RANDOM % 127)
                j=0
              fi
            done

          #una volta superati tutti i check con gli elementi già in lista, posso inserire quello nuovo
          if [ $j -eq $i ]; then
            lista+=($toInsert)
          fi
          i=$(($i + 1))
        fi
      done

    #inserisco l'address da codificare
    #addressToEncode=$(expr $RANDOM % 127)
    addressToEncode=8
    lista+=($addressToEncode)

    ##
    #blocco di codice in cui calcolo il risultato atteso
    #e lo inserisco in posizione 8
    ##
    analyzedWZ=0
    isMatching=0
    while [[ $analyzedWZ -lt 8 && $isMatching -lt 1 ]]
      do
        offsetFromWzBase=$((${lista[8]} - ${lista[$analyzedWZ]}))
        if [[ $offsetFromWzBase -gt 3 || $offsetFromWzBase -lt 0 ]]; then #caso in cui non appartiene alla wz analizzata
          analyzedWZ=$(($analyzedWZ + 1))

        else #caso in cui appartiene alla wz, quindi devo calcolare il risultato atteso
          isMatching=1
          shiftedMatchingWzBin=$(($analyzedWZ * 16)) #codifica binaria del numero della WZ con cui matcha, con quadruplo left shift

          ##qui inserisco lo switch case per la codifica oneHot dell'offset
          case $offsetFromWzBase in
            0) onehotOffsetFromWzBase=0;;
            1) onehotOffsetFromWzBase=2;;
            2) onehotOffsetFromWzBase=4;;
            3) onehotOffsetFromWzBase=8;;
          esac

          finalValueDec=$((128 + $shiftedMatchingWzBin + $onehotOffsetFromWzBase))
          lista+=($finalValueDec)
          break
        fi
      done

    if [ $isMatching=0 ]; then #caso in cui non c'è nessuna wz matching
      toInsert=${lista[8]}
      lista+=($toInsert)
    fi

    #uso questo loop per prendere i numeri dalla lista creata sopra
    #e piazzarli nel file
    for i in {0..9}
      do
          echo -n "${lista[$i]} " >> autogenTests/$1 #ok questa è la sintassi corretta per accesso alla lista
      done

    printf "\n" >> autogenTests/$1
  done
