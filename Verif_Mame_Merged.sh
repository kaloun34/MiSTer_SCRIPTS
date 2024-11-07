#!/bin/bash

### Tonton ###
# (07/11/2024)

MIST="/media/fat"
DIRM="/media/fat/Games/mame"
url="https://myrient.erista.me/files/Internet%20Archive/chadmaster/mame-merged/mame-merged"
SSL_SECURITY_OPTION="--insecure"
CURL_RETRY="--connect-timeout 15 --max-time 180 --retry 3 --retry-delay 5 --show-error"


# Renomme du core et parcours web
search() {
  for mame in "$DIRM"/*.zip; do
    MAME=${mame##*/}
    curl $CURL_RETRY $SSL_SECURITY_OPTION --fail --location --output /dev/null "$url/$MAME">/dev/null 2>&1
    error_code=$?

    if [ "$error_code" -eq 0 ]; then
      echo "$MAME est une rom merged"
    else
      echo "$MAME n'est a priori pas une rom merged" >> $MIST/MameMerged_NOK.txt
    fi
  done
}


#Début du script
if [ -f $MIST/MameMerged_NOK.txt ]; then
	rm $MIST/MameMerged_NOK.txt
fi
search