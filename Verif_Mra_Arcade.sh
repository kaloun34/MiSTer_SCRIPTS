#!/bin/bash

### Tonton ###
# (11/01/2023)

MIST="/media/fat"
DIRC="/media/fat/_Arcade/cores"
DIRA="/media/fat/_Arcade"

# Extraction du core
core() {
cd "$1"
for MRA in *.mra; do
    COREOK=""
    CORE=""

    if [ ! -f "$MRA" ]; then
        echo "Aucun fichier .mra trouvé dans le répertoire."
        break  # Sortir si aucun fichier n'est trouvé
    fi
     # Recherche de la ligne qui commence par <rbf>
     ligne=$(grep "<\/rbf>" "$MRA")
	if [ -n "$ligne" ]; then
		# Si une ligne est trouvée, récupération du nom du core entre les balises <rbf>
        #CORE=$(echo $ligne | sed -n 's/.*<rbf>\(.*\)<\/rbf>.*/\1/p')
        CORE=$(echo "$ligne" | sed -n 's/.*>\(.*\)<\/rbf>.*/\1/p')
        COROK=$(find "$DIRC" -maxdepth 1 -iname "$CORE*")
        if [ -n "$COROK" ]; then
			echo "$CORE OK"
        else
			echo "$CORE NOK"
            echo "$CORE --> $DIRMRA/$MRA">>$MIST/MRA_NOK.txt
		fi
    fi
done
}

# Parcours des MRA
MRASearch () {
find "$DIRA" -type d | while read -r DIRMRA; do
	core "$DIRMRA"
done
}

#Début du script
if [ -f $MIST/MRA_NOK.txt ]; then
    rm $MIST/MRA_NOK.txt
fi
MRASearch
