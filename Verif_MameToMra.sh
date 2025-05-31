#!/bin/bash

### Tonton ###
# (25/10/2024)
#
# Vérifie si les ROMS Mame du dossiers /Games/mame et sont bien utilisés par un MRA des dossiers /_Arcade et /_MiSTer++/_DualSDRAM/_Arcade


# Arrêt immédiat en cas d'erreur, etc....
# FIXME: set -euo pipefail (ne fonctionne pas dans ce contexte, à creuser...)

# Déclaration variables
readonly MIST="/media/fat"
readonly DIRM="/media/fat/Games/mame"
readonly DIRHM="/media/fat/Games/hbmame"
readonly DIRA="/media/fat/_Arcade"
readonly DIRAD="/media/fat/_MiSTer++/_DualSDRAM/_Arcade"
readonly TEMP="/media/fat/Scripts/.tonton"
readonly OUT="MameToMra_NOK.txt"
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

    printf "Ces ROMS ne semblent pas être utilisés par un MRA Arcade:\n">"$MIST/$OUT"
    printf ".\n"
    printf "Verification des ROMS en cours ....\n"
    printf ".\n"
    index_MRA
    MRASearch
    rm -f "$INDEX"
}

# Création d'un fichier index
# il est intuile de reparcourir tous les MRAs à chaque occurence de $zip
index_MRA() {
    printf "Extraction brute des lignes contenant .zip dans les MRA...\n"
    find "$DIRA" "$DIRAD" -type f -name "*.mra" -print0 | xargs -0 grep -i '\.zip' > "$INDEX"
}

# Parcours des MRA
MRASearch () {
    for zip in "$DIRM"/*.zip "$DIRHM"/*.zip; do
        rom="${zip##*/}"

        if ! grep -Fq "$rom" "$INDEX"; then
            printf "%s NOK\n" "$rom"
            printf "%s\n" "$rom" >> "$MIST/$OUT"
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
