#!/bin/bash

### Tonton ###
# (25/10/2024)


# Arrêt immédiat en cas d'erreur, etc....
# FIXME: set -euo pipefail (ne fonctionne pas dans ce contexte, à creuser...)

# Déclaration variables
readonly MIST="/media/fat"
readonly DIRM="/media/fat/Games/mame"
readonly DIRHM="/media/fat/Games/hbmame"
readonly DIRA="/media/fat/_Arcade"
readonly OUT="MraToMameMerged_NOK.txt"
# --- Couleurs terminal ---
readonly RED=$'\033[31m'
readonly RESET=$'\033[0m'

shopt -s nullglob


# === Fonction : main ===
main() {
	if [ -f $MIST/"$OUT" ]; then
		rm $MIST/"$OUT"
	fi

	printf "Ces MRA pointent vers un fichier mame non Merged dans /Games/mame ou /Games/hbmame:\n">"$MIST/$OUT"
    printf "\n">>"$MIST/$OUT"
    printf ".\n"
    printf "Verification des MRA en cours ....\n"
    printf ".\n"
	MRASearch
}

# Extraction du core
core() {
	cd "$1" || exit
	for mra in *.mra; do
		if [ ! -f "$mra" ]; then
			printf "Aucun fichier .mra trouvé dans le répertoire.\n"
			break
		fi

		# Recherche de la ligne qui commence par <rom
		ligne=$(grep -m 1 '<rom.*zip=' "$mra")

		if [ -n "$ligne" ]; then
			if ! echo "$ligne" | grep -qE 'zip=["'\''"]([^"'\''"]*\.zip)'; then
				#printf "Aucun fichier zip trouvé pour %s/%s\n" "$DIRMRA" "$mra">>"$MIST/$OUT"
				continue
			fi

			mames=($(echo "$ligne" | sed -n "s/.*zip=['\"]\([^'\"]*\)['\"].*/\1/p" | tr '|' '\n' | grep '\.zip$'))
			local mameok=()
			local mame=""
			local taille=${#mames[@]}
			local compteur=0

			if [ "$taille" -gt 1 ]; then
				for mame in "${mames[@]}"; do
					mame_found=$(find "$DIRM" "$DIRHM" -maxdepth 1 -iname "$mame")

					if [ -n "$mame_found" ] && [[ "$mame_found" != *"qsound.zip"* ]] && [[ "$mame_found" != *"namco"* ]]; then
						((compteur++))
						mameok+=("${mame_found#/media/fat/Games/}")
					fi
				done

				if [ "$compteur" -gt 1 ]; then
					echo "Le MRA merged:  \"$(echo "$1" | sed 's|^/media/fat||')/$MRA\"  pointe sur $compteur fichiers mames:  ${mameok[@]}" >> "$MIST/$OUT"
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

# === Fonction : cleanup ===
# Non fonctionnelle pour le moment
cleanup() {
    printf "\n%sInterruption détectée. Nettoyage...%s\n" "$RED" "$RESET" >&2
    #exit 1
	return 1
}

main "$@"
