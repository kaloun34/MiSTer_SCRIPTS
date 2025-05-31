#!/bin/bash

### Tonton ###
# (11/01/2023)
#
# # Vérifie si les MRA du dossier /_Arcade pointent bien vers un Core dans /_Arcade/cores


# Arrêt immédiat en cas d'erreur, etc....
# FIXME: set -euo pipefail (ne fonctionne pas dans ce contexte, à creuser...)

# Déclaration variables
readonly MIST="/media/fat"
readonly DIRC="/media/fat/_Arcade/cores"
readonly DIRCP="/media/fat/_MiSTer++/cores"
readonly DIRA="/media/fat/_Arcade"
readonly DIRAD="/media/fat/_MiSTer++/_DualSDRAM/_Arcade"
readonly DIRAL="/media/fat/_MiSTer++/_LLAPI/_Arcade"
readonly TEMP="/media/fat/Scripts/.tonton"
readonly OUT="MraToCore_NOK.txt"
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

    printf "Ces MRA pointent vers un Core inexistant dans /_Arcade/cores:\n">"$MIST/$OUT"
    printf "\n">>"$MIST/$OUT"
    printf ".\n"
    printf "Verification des MRA en cours ....\n"
    printf ".\n"
    index_MRA
    MRASearch
    rm -f "$INDEX"
}

# Création d'un fichier index
# il est intuile de reparcourir tous les MRAs à chaque occurence de $zip
index_MRA() {
    printf "Extraction brute des lignes contenant <\/rbf> dans les MRA...\n"
    find "$DIRA" "$DIRAD" "$DIRAL" -type f -name "*.mra" -print0 | xargs -0 grep -i '<\/rbf>' > "$INDEX"
}

# Parcours des MRA
MRASearch () {
    while IFS= read -r line; do
        mra_path="${line%%:*}"
        core_name=$(echo "$line" | sed -n 's/.*<rbf>\(.*\)<\/rbf>.*/\1/p')
        shopt -s nullglob #assure que le tableau soit vide si le core n'existe pas
        matches=( "$DIRC"/"$core_name"_*.rbf "$DIRCP"/"$core_name"_*.rbf )
        shopt -u nullglob
        if [ ${#matches[@]} -eq 0 ]; then
            all_cores=( "$DIRC"/*.rbf )
            for f in "${all_cores[@]}"; do
                base="${f##*/}"
                name="${base%%_*}"
                if [[ "${name,,}" == "${core_name,,}" ]]; then
                    printf "%s --> %s  Mauvaise casse : %s (attendu : %s)\n" "$core_name" "$mra_path" "$base" "$core_name" >> "$MIST/$OUT"
                    continue 2
                fi
            done

            # aucun match même avec mauvaise casse
            printf "%s NOK\n" "$core_name"
            printf "%s --> %s\n" "$core_name" "$mra_path" >> "$MIST/$OUT"
        fi
    done < "$INDEX"
}

# === Fonction : cleanup ===
# Non fonctionnelle pour le moment
cleanup() {
    printf "\n%sInterruption détectée. Nettoyage...%s\n" "$RED" "$RESET" >&2
    #exit 1
	return 1
}

main "$@"
