#!/bin/bash

### Tonton ###
# (10/01/2023)

MIST="/media/fat"
DIRC="/media/fat/_Arcade/cores"
DIRA="/media/fat/_Arcade"
Test=0


# Renomme du core
renomme() {
for core in $DIRC/*.rbf;do
	CORE=${core##*/} #supprime chemin du nom du fichier
	#CORE=${CORE%%_*} #supprime tout à partir de _ du nom du fichier
	CORE=${CORE%?????????????*} #supprimer les 8 derniers caractères du nom de fichier + l'extension
	CORE=$(echo $CORE | tr "A-Z" "a-z")
	#CORE=\<rbf\>$CORE\<\/rbf\>
	CORE=$CORE\<\/rbf\>
	MRASearch
	if [ $? -eq 1 ]; then
		echo $core OK
	else
		echo $core NOK
		echo $core>>$MIST/Cores_NOK.txt
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
if [ -f $MIST/Cores_NOK.txt ]; then
	rm $MIST/Cores_NOK.txt
fi
renomme
