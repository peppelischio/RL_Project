# il testbench genera gruppi di 10 numeri alla volta sulla stessa linea e separati da uno spazio.

# i primi 8 numeri sono le basi delle working zones, che devono essere distanti almeno 4 indirizzi fra di loro, e non per forza in ordine

# il nono numero è l'indirizzo da codificare compreso fra 0 e 127

# il decimo numero è la codifica del numero, quindi bisogna riprodurre nel testbench il behaviour del programma.


# 1 generare gli 8 indirizzi working zone
# il numero generato non deve cadere nei 4 indirizzi delle basi gia create, e le basi gia create non devono cadere nei 4 indirizzi della base generata
# Esempio: Se ad una certa posizione trovo una wz con base 20 allora devo generare una nuova base che sia minore di 17 e maggiore di 23
# Quindi 19 e 22 non sono validi, 15 e 25 si, e devo eseguire questo check per tutte le basi.

import random

for i in range(0, 4000):

    wzList = []
    isColliding = False
    isInWz = False
    addressPos = 0
    offsetDistance = 0
    binaryRep = str
    onehotString = str
    wzString = str
    oneHotRep = 0
    encodedValue = 0

    randBase = random.randint(0, 128)
    wzList.append(randBase)
    randAddress = 0

    while len(wzList) < 8:

        randBase = random.randint(0, 127)

        for y in range(0, len(wzList)):
            if randBase < wzList[y] - 3 or randBase > wzList[y] + 3:
                continue
            else:
                isColliding = True
                break

        if isColliding:
            isColliding = False
            continue
        else:
            wzList.append(randBase)

    randAddress = random.randint(0, 127)

    for z in range(0, len(wzList)):

        if randAddress < wzList[z] or randAddress > wzList[z] + 3:
            continue
        else:
            isInWz = True
            addressPos = z
            offsetDistance = randAddress - wzList[z]
            break

    if isInWz:
        # qua devo scrivere la stringa binaria

        # unica cosa da encoddare è l'offset, che si puo fare come 2^(wzoffset) per creare la codifica onehot

        oneHotRep = 2 ** offsetDistance

        onehotString = '{0:04b}'.format(oneHotRep)

        wzString = '{0:03b}'.format(addressPos)

        binaryRep = '1' + wzString + onehotString

        encodedValue = int(binaryRep, 2)

        print(wzList, isInWz, randAddress, addressPos, offsetDistance, encodedValue, binaryRep)

    else:
        # qua devo riscrivere il nome
        encodedValue = randAddress
        print(wzList, isInWz, randAddress)

    # Ora resta solo da scrivere su file i test

    testFile = open("testBenchLollo.txt", "a+")

    for w in range(0, len(wzList)):
        testFile.write(str(wzList[w]) + " ")

    testFile.write(str(randAddress) + " ")

    testFile.write(str(encodedValue) + "\n")

    testFile.close()
