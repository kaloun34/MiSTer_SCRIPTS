#!/bin/bash

### Tonton ###
# (25/10/2024)

MIST="/media/fat"
DIRM="/media/fat/Games/mame"
DIRHM="/media/fat/Games/hbmame"
DIRA="/media/fat/_Arcade"
DIRC="/media/fat/_Arcade/cores"

shopt -s nullglob  # Cette option emp�che les jokers vides de produire des noms de fichiers litt�raux.

# Extraction du core
core() {
cd "$1"
for MRA in *.mra; do
    if [ ! -f "$MRA" ]; then
        echo "Aucun fichier .mra trouv� dans le r�pertoire."
        break  # Sortir si aucun fichier n'est trouv�
    fi

    # Recherche de la ligne qui commence par <rom
    #ligne=$(grep "<rom" "$MRA")
	ligne=$(grep -m 1 '<rom.*zip=' "$MRA")

	if [ -n "$ligne" ]; then
        if ! echo "$ligne" | grep -qE 'zip=["'\''"]([^"'\''"]*\.zip)'; then
            #echo "Aucun fichier zip trouv� pour $DIRMRA/$MRA"
            continue
        fi

        MAMES=($(echo "$ligne" | sed -n "s/.*zip=['\"]\([^'\"]*\)['\"].*/\1/p" | tr '|' '\n' | grep '\.zip$'))
        MAMEOK=()
        MAME=""
        taille=${#MAMES[@]}
        compteur=0

        if [ "$taille" -gt 1 ]; then
            for MAME in "${MAMES[@]}"; do
                MAME_FOUND=$(find "$DIRM" "$DIRHM" -maxdepth 1 -iname "$MAME")

                if [ -n "$MAME_FOUND" ]; then
                    ((compteur++))
                    MAMEOK+=("${MAME_FOUND#/media/fat/Games/}")
                fi
            done

            if [ "$compteur" -gt 1 ]; then
                echo "Le MRA merged:  \"$(echo "$1" | sed 's|^/media/fat||')/$MRA\"  pointe sur $compteur fichiers mames:  ${MAMEOK[@]}" >> "$MIST/MRAMAMEMERGED_NOK.txt"
            fi
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

#D�but du script
if [ -f $MIST/MRAMAMEMERGED_NOK.txt ]; then
    rm $MIST/MRAMAMEMERGED_NOK.txt
fi
MRASearch
