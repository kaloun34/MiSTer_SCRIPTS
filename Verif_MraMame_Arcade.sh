#!/bin/bash

### Tonton ###
# (25/10/2024)

MIST="/media/fat"
DIRM="/media/fat/Games/mame"
DIRHM="/media/fat/Games/hbmame"
DIRA="/media/fat/_Arcade"
DIRC="/media/fat/_Arcade/cores"

shopt -s nullglob  # Cette option empêche les jokers vides de produire des noms de fichiers littéraux.

# Extraction du core
core() {
cd "$1"
for MRA in *.mra; do
    if [ ! -f "$MRA" ]; then
        echo "Aucun fichier .mra trouvé dans le répertoire."
        break  # Sortir si aucun fichier n'est trouvé
    fi

    # Recherche de la ligne qui commence par <rom
    #ligne=$(grep "<rom" "$MRA")
	ligne=$(grep -m 1 '<rom.*zip=' "$MRA")

	if [ -n "$ligne" ]; then
        if ! echo "$ligne" | grep -qE 'zip=["'\''"]([^"'\''"]*\.zip)'; then
            echo "Aucun fichier zip trouvé pour $DIRMRA/$MRA">>"$MIST/MRAMAME_NOK.txt"
            continue
        fi

        MAMES=($(echo "$ligne" | sed -n "s/.*zip=['\"]\([^'\"]*\)['\"].*/\1/p" | tr '|' '\n' | grep '\.zip$' | xargs -n 1 basename))
        MAMEOK=""
        MAME=""

        for MAME in "${MAMES[@]}"; do
            MAME_FOUND=$(find "$DIRM" "$DIRHM" -maxdepth 1 -iname "$MAME")

            if [ -n "$MAME_FOUND" ]; then
			    echo "$MAME OK"
                MAMEOK="$MAME"
                #echo "$MAME --> $DIRMRA/$MRA">>"$MIST/MRAMAME_OK.txt"
                break
		    fi
        done

        if [ -z "$MAMEOK" ]; then
            echo "$MAME NOK"
            echo "$MAME --> $DIRMRA/$MRA">>"$MIST/MRAMAME_NOK.txt"
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
if [ -f $MIST/MRAMAME_NOK.txt ]; then
    rm $MIST/MRAMAME_NOK.txt
fi
MRASearch
