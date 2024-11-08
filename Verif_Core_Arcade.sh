#!/bin/bash

### Tonton ###
# (10/01/2023)
#
# Vérifie si les Cores du dossier /arcade/cores sont utilisés par un MRA de /_Arcade

MIST="/media/fat"
DIRC="/media/fat/_Arcade/cores"
DIRA="/media/fat/_Arcade"
Test=0


# Renomme du core
renomme() {
for core in $DIRC/*.rbf;do
	CORE=${core##*/} #supprime chemin du nom du fichier
	CORE=${CORE%?????????????*} #supprimer les 8 derniers caractères du nom de fichier + l'extension
	CORE=$(echo $CORE | tr "A-Z" "a-z")
	CORE=$CORE\<\/rbf\>
	MRASearch
	if [ $? -ne 1 ]; then
		echo "$core NOK"
		echo "$core">>"$MIST"/Cores_NOK.txt
	fi
done
}

# Parcours des MRA
MRASearch () {
shopt -s nullglob globstar
for MRA in "$DIRA"/**/*.mra ;do
	if grep -qi "$CORE" "$MRA" ;then
		return 1
	fi
done
}

#Début du script
if [ -f "$MIST"/Cores_NOK.txt ]; then
	rm "$MIST"/Cores_NOK.txt
fi

echo "Ces Cores du dossier /_Arcade/cores ne semblent pas être utilisés par un MRA Arcade:">"$MIST"/Cores_NOK.txt
echo "">>"$MIST"/Cores_NOK.txt
echo .
echo "Verification des cores en cours ...."
echo .
renomme
