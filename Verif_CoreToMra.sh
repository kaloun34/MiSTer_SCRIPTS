#!/bin/bash

### Tonton ###
# (10/01/2023)
#
# Vérifie si les Cores du dossier /_Arcade/cores sont utilisés par un MRA de /_Arcade


# Arrêt immédiat en cas d'erreur, etc....
# FIXME: set -euo pipefail (ne fonctionne pas dans ce contexte, à creuser...)

# Déclaration variables
readonly MIST="/media/fat"
readonly DIRC="/media/fat/_Arcade/cores"
readonly DIRA="/media/fat/_Arcade"
readonly OUT="CoreToMra_NOK.txt"
readonly TEMP="/media/fat/Scripts/.tonton"
INDEX="$TEMP/index.txt"
# --- Couleurs terminal ---
readonly RED=$'\033[31m'
readonly RESET=$'\033[0m'

# FIXME: trap 'cleanup' INT TERM # Capture des signaux INT et TERM pour nettoyage propre (ne fonctionne pas)

# === Fonction : main ===
main() {
	if [ -f "$MIST/$OUT" ]; then
		rm "$MIST/$OUT"
	fi

	printf "Ces Cores ne semblent pas être utilisés par un MRA Arcade:\n">"$MIST/$OUT"
	printf ".\n"
	printf "Verification des Cores en cours ....\n"
	printf ".\n"
	index_MRA
	coresearch
	#rm -f "$INDEX"
}

# Création d'un fichier index
# il est intuile de reparcourir tous les MRAs à chaque occurence de $zip
index_MRA() {
    printf "Extraction brute des lignes contenant <\/rbf> dans les MRA...\n"
	#TODO rajouter "$DIRAD" "$DIRAL"
    find "$DIRA"   -type f -name "*.mra" -print0 | xargs -0 grep -i '<\/rbf>' > "$INDEX"
}


# Parcours des cores
coresearch() {
for core in "$DIRC"/*.rbf;do
	local core_name=${core##*/} #supprime chemin du nom du fichier
	core_name=${core_name%?????????????*} #supprimer les 8 derniers caractères du nom de fichier + l'extension
	core_name=$(echo "$core_name" | tr "A-Z" "a-z")
	core_name=$core_name\<\/rbf\>

    if ! grep -qi "$core_name" "$INDEX"; then
        printf "%s NOK\n" "$core"
        printf "%s\n" "$core" >> "$MIST/$OUT"
    fi
done
}

# === Fonction : cleanup ===
# Non fonctionnelle pour le moment
cleanup() {
    printf "\n%sInterruption détectée. Nettoyage...%s\n" "$RED" "$RESET" >&2
    #exit 1
	return 1
}

main "$@"
