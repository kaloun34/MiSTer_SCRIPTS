#!/bin/bash

### Tonton ###
# (07/11/2024)


# Arrêt immédiat en cas d'erreur, etc....
# FIXME: set -euo pipefail (ne fonctionne pas dans ce contexte, à creuser...)

# Déclaration variables
readonly MIST="/media/fat"
readonly DIRM="/media/fat/Games/mame"
readonly OUT="MameToMameMergedOnline_NOK.txt"
# Variables pour wget ou curl
readonly URL="https://myrient.erista.me/files/Internet%20Archive/chadmaster/mame-merged/mame-merged"
readonly SSL_SECURITY_OPTION="--insecure"
readonly CURL_RETRY="--connect-timeout 15 --max-time 180 --retry 3 --retry-delay 5 --show-error"
# --- Couleurs terminal ---
readonly RED=$'\033[31m'
readonly RESET=$'\033[0m'

# FIXME: trap 'cleanup' INT TERM # Capture des signaux INT et TERM pour nettoyage propre (ne fonctionne pas)


# === Fonction : main ===
main() {
	if [ -f $MIST/"$OUT" ]; then
    rm $MIST/"$OUT"
	fi

  search
}

# Renomme du core et parcours web
search() {
  for mame in "$DIRM"/*.zip; do
    mame=${mame##*/}
    curl $CURL_RETRY $SSL_SECURITY_OPTION --fail --location --output /dev/null "$URL/$mame">/dev/null 2>&1
    error_code=$?

    if [ "$error_code" -eq 0 ]; then
      printf "%s est une rom merged          \r" "$mame"
    else
      printf "%s n'est a priori pas une rom merged\n" "$mame" >> $MIST/MameMerged_NOK.txt
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
