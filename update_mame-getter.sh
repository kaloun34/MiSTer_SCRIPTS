#!/bin/bash
#set -x

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


#Q: How does it work?
#A: Download it to the Scripts Directory and run it like any other MiSTer update script. This script looks for .mra files in _Arcade and its recursive directories and tries to download the MAME merged set zip files listed in the .mra files. At the bottom of the script is a list of all the merged MAME roms for the .220 set. Only rom files with names that match this list will be downloaded.  
#
#Q: Can I set my own custom loactions for MRA and MAME files? 
#A: A /media/fat/Scripts/update_mame-getter.ini file may be used to set custom location for your MAME files and MRA files.
#Add the following line to the ini file to set a directory for MRA files: MRADIR=/top/path/to/mra/files
#Add the following line to the ini file to set a directory for MAME files: ROMDIR=/path/to/mame
#
#Q:Will this script over write files I already have?
#A:NO, This script will not clober files you already have. You need to manaully remove any files you have if you want to download new files.
#
#A Merged set contains all of the files for every Clone version of a Parent game.
#
#USE AT YOUR OWN RISK - THIS COMES WITHOUT WARRANTE AND MAY KILL BABY SEALS.
##############################################################################

echo "STARTING: MAME-GETTER"
echo ""

# ========= OPTIONS ==================
ALLOW_INSECURE_SSL="true"
CURL_RETRY="--connect-timeout 15 --max-time 180 --retry 3 --retry-delay 5 --show-error"
# ========= CODE STARTS HERE =========

INI_PATH="$(pwd)/update_mame-getter.ini"
if [ -f "${INI_PATH}" ] ; then
    TMP=$(mktemp)
    dos2unix < "${INI_PATH}" 2> /dev/null | grep -v "^exit" > ${TMP} || true

    if [ $(grep -c "ALLOW_INSECURE_SSL=" "${TMP}") -gt 0 ] ; then
        ALLOW_INSECURE_SSL=$(grep "ALLOW_INSECURE_SSL=" "${TMP}" | awk -F "=" '{print$2}' | sed -e 's/^ *// ; s/ *$// ; s/^"// ; s/"$//')
    fi 2> /dev/null

    if [ $(grep -c "CURL_RETRY=" "${TMP}") -gt 0 ] ; then
        CURL_RETRY=$(grep "CURL_RETRY=" "${TMP}" | awk -F "=" '{print$2}' | sed -e 's/^ *// ; s/ *$// ; s/^"// ; s/"$//')
    fi 2> /dev/null

    rm ${TMP}
fi

SSL_SECURITY_OPTION=""

set +e
curl ${CURL_RETRY} "https://github.com" > /dev/null 2>&1
RET_CURL=$?
set -e

case ${RET_CURL} in
    0)
        ;;
    *)
        if [[ "${ALLOW_INSECURE_SSL}" == "true" ]]
        then
            SSL_SECURITY_OPTION="--insecure"
        else
            echo "CA certificates need"
            echo "to be fixed for"
            echo "using SSL certificate"
            echo "verification."
            echo "Please fix them i.e."
            echo "using security_fixes.sh"
            exit 2
        fi
        ;;
    *)
        echo "No Internet connection"
        exit 1
        ;;
esac

echo "Downloading the most recent mame-merged-set-getter script."
echo " "
curl \
    ${CURL_RETRY} \
    ${SSL_SECURITY_OPTION} \
    --fail \
    --location \
    -o /tmp/mame-merged-set-getter.sh \
    https://raw.githubusercontent.com/kaloun34/MiSTer_SCRIPTS/master/mame-merged-set-getter.sh

chmod +x /tmp/mame-merged-set-getter.sh

export CURL_RETRY
export ALLOW_INSECURE_SSL
export SSL_SECURITY_OPTION

/tmp/mame-merged-set-getter.sh

rm /tmp/mame-merged-set-getter.sh

echo "FINISHED: MAME-GETTER"
