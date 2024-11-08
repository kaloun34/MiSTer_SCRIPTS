#!/bin/bash

### Tonton ###
# (25/10/2024)
#
# Vérifie si les ROMS Mame du dossiers /Games/mame et sont bien utilisés par un MRA des dossiers /_Arcade et /_MiSTer++/_DualSDRAM/_Arcade


MIST="/media/fat"
DIRM="/media/fat/Games/mame"
DIRHM="/media/fat/Games/hbmame"
DIRA="/media/fat/_Arcade"
DIRAD="/media/fat/_MiSTer++/_DualSDRAM/_Arcade"


# Renomme du core
renomme() {
for mame in "$DIRM"/*.zip "$DIRHM"/*.zip; do
    MAME="${mame##*/}"
    MRASearch

    if [ $? -ne 1 ]; then
        echo "$mame NOK"
        echo "$mame" >> "$MIST/Mame_NOK.txt"
    fi
    done
}

# Parcours des MRA
MRASearch () {
shopt -s nullglob globstar
for MRA in "$DIRA"/**/*.mra "$DIRAD"/**/*.mra ;do
	if grep -qi "$MAME" "$MRA" ;then
		return 1
	fi
done

shopt -u nullglob globstar
return 0
}

#Début du script
if [ -f "$MIST"/Mame_NOK.txt ]; then
	rm "$MIST"/Mame_NOK.txt
fi

echo "Ces ROMS ne semblent pas être utilisés par un MRA Arcade:">"$MIST"/Mame_NOK.txt
echo "">>"$MIST"/Mame_NOK.txt
echo .
echo "Verification des Cores en cours ...."
echo .
renomme
