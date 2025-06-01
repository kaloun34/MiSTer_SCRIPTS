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
readonly OUT="MraToMame_NOK.txt"
# --- Couleurs terminal ---
readonly RED=$'\033[31m'
readonly RESET=$'\033[0m'

# FIXME: trap 'cleanup' INT TERM # Capture des signaux INT et TERM pour nettoyage propre (ne fonctionne pas)


shopt -s nullglob  # Cette option empêche les jokers vides de produire des noms de fichiers littéraux.

# === Fonction : main ===
main() {
	if [ -f "$MIST/$OUT" ]; then
		rm "$MIST/$OUT"
	fi
    printf "Ces MRA référencent des sets MAME absents de /Games/mame et /Games/hbmame :\n\n" > "$MIST/$OUT"
    printf ".\nVérification des MRA en cours...\n.\n"
	MRASearch
}

# Extraction du core
core() {
    local dirmra=$1
    cd "$dirmra" || exit
    for MRA in *.mra; do
        if [ ! -f "$MRA" ]; then
            printf "Aucun fichier .mra trouvé dans le répertoire.\n"
            break  # Sortir si aucun fichier n'est trouvé
        fi

        # Recherche de la ligne qui commence par <rom
        #ligne=$(grep "<rom" "$MRA")
        ligne=$(grep -m 1 '<rom.*zip=' "$MRA")

        if [ -n "$ligne" ]; then
            if ! echo "$ligne" | grep -qE 'zip=["'\''"]([^"'\''"]*\.zip)'; then
                printf "Aucun fichier zip trouvé pour %s/%s\n" "$dirmra" "$MRA">>"$MIST/$OUT"
                continue
            fi

            mames=($(echo "$ligne" | sed -n "s/.*zip=['\"]\([^'\"]*\)['\"].*/\1/p" | tr '|' '\n' | grep '\.zip$' | xargs -n 1 basename))
            mameok=""
            mame=""

            for mame in "${mames[@]}"; do
                mame_found=$(find "$DIRM" "$DIRHM" -maxdepth 1 -iname "$mame")

                if [ -n "$mame_found" ]; then
                    printf "%s OK          \r" "$mame"
                    mameok="$mame"
                    break
                fi
            done

            if [ -z "$mameok" ]; then
                printf "%s NOK\n" "$mame"
                printf "%s --> %s/%s\n" "$mame" "$dirmra" "$MRA">>"$MIST/$OUT"
            fi
        fi
    done
}

# Parcours des MRA
MRASearch () {
    find "$DIRA" -type d | while read -r dirmra; do
        core "$dirmra"
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
