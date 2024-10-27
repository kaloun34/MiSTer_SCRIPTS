#!/bin/bash

### Tonton ###
# (25/10/2024)

MIST="/media/fat"
DIRM="/media/fat/Games/mame"
DIRA="/media/fat/_Arcade"
DIRAD="/media/fat/_MiSTer++/_DualSDRAM/_Arcade"
Test=0


# Renomme du core
renomme() {
for mame in $DIRM/*.zip;do
    MAME=${mame##*/}
	MRASearch
	if [ $? -eq 1 ]; then
		echo $mame OK
	else
		echo $mame NOK
		echo $mame>>$MIST/Mame_NOK.txt
	fi
done
}

# Parcours des MRA
MRASearch () {
shopt -s nullglob globstar
for MRA in $DIRA/**/*.mra "$DIRAD"/**/*.mra ;do
	if grep -qi "$MAME" "$MRA" ;then
		return 1
	fi
done
}

#Début du script
if [ -f $MIST/Mame_NOK.txt ]; then
	rm $MIST/Mame_NOK.txt
fi
renomme
