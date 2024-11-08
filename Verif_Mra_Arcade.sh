#!/bin/bash

### Tonton ###
# (11/01/2023)
#
# # Vérifie si les MRA du dossier /_Arcade pointent bien vers un Core dans /_Arcade/cores

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
        break  # Sortir si aucun fichier n'est trouvé
    fi

     # Recherche de la ligne qui fini par </rbf>
     ligne=$(grep "<\/rbf>" "$MRA")

	if [ -n "$ligne" ]; then
		# Si une ligne est trouvée, récupération du nom du core entre les balises <rbf>
        CORE=$(echo "$ligne" | sed -n 's/.*>\(.*\)<\/rbf>.*/\1/p')
        COROK=$(find "$DIRC" -maxdepth 1 -iname "$CORE*")
        if [ -z "$COROK" ]; then
			echo "$CORE OK"
			echo "$CORE NOK"
            echo "$CORE --> $DIRMRA/$MRA">>"$MIST"/MRA_NOK.txt
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
if [ -f "$MIST"/MRA_NOK.txt ]; then
    rm "$MIST"/MRA_NOK.txt
fi

echo "Ces MRA pointent sur un Core qui n'existe pas dans /_Arcade/cores:">"$MIST"/MRA_NOK.txt
echo "">>"$MIST"/MRA_NOK.txt
echo .
echo "Verification des MRA en cours ...."
echo .
MRASearch
