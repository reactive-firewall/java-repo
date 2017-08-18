#! /bin/bash

# this file is from PAK

################################################################################
#
# ANY USAGE OR RELIANCE ON PAK TOOLS SOFTWARE CONSTITUTES AGREEMENT AND
# ACKNOWLEDGMENT TO THE FOLLOWING.
#
# Disclaimer of Warranties. 
# A. YOU EXPRESSLY ACKNOWLEDGE AND AGREE THAT, TO THE EXTENT PERMITTED BY
#    APPLICABLE LAW, USE OF THIS SHELL SCRIPT AND ANY SERVICES PERFORMED
#    BY OR ACCESSED THROUGH THIS SHELL SCRIPT IS AT YOUR SOLE RISK AND
#    THAT THE ENTIRE RISK AS TO SATISFACTORY QUALITY, PERFORMANCE, ACCURACY AND
#    EFFORT IS WITH YOU.
#
# B. TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THIS SHELL SCRIPT
#    AND SERVICES ARE PROVIDED "AS IS" AND “AS AVAILABLE”, WITH ALL FAULTS AND
#    WITHOUT WARRANTY OF ANY KIND, AND THE AUTHOR OF THIS SHELL SCRIPT AND ITS
#    LICENSORS (COLLECTIVELY REFERRED TO AS "THE AUTHOR OF THIS SHELL SCRIPT"
#    FOR THE PURPOSES OF THIS DISCLAIMER)
#    HEREBY DISCLAIM ALL WARRANTIES AND CONDITIONS WITH RESPECT TO THIS SHELL
#    SCRIPT AND SERVICES, EITHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT
#    NOT LIMITED TO, THE IMPLIED WARRANTIES AND/OR CONDITIONS OF
#    MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE,
#    ACCURACY, QUIET ENJOYMENT, AND NON-INFRINGEMENT OF THIRD PARTY RIGHTS. 
#    
# C. THE AUTHOR OF THIS SHELL SCRIPT DOES NOT WARRANT AGAINST INTERFERENCE WITH
#    YOUR ENJOYMENT OF THE THE AUTHOR OF THIS SHELL SCRIPT AND SERVICES, THAT
#    THE FUNCTIONS CONTAINED IN, OR SERVICES PERFORMED OR PROVIDED BY, THIS
#    SHELL SCRIPT WILL MEET YOUR REQUIREMENTS, THAT THE OPERATION OF THIS SHELL
#    SCRIPT OR SERVICES WILL BE UNINTERRUPTED OR ERROR-FREE, THAT ANY SERVICES
#    WILL CONTINUE TO BE MADE AVAILABLE, THAT THIS SHELL SCRIPT OR SERVICES WILL
#    BE COMPATIBLE OR WORK WITH ANY THIRD PARTY SOFTWARE, APPLICATIONS OR THIRD
#    PARTY SERVICES, OR THAT DEFECTS IN THIS SHELL SCRIPT OR SERVICES WILL BE
#    CORRECTED. INSTALLATION OF THIS THE AUTHOR OF THIS SHELL SCRIPT SOFTWARE
#    MAY AFFECT THE USABILITY OF THIRD PARTY SOFTWARE, APPLICATIONS OR THIRD
#    PARTY SERVICES.
#
# D. YOU FURTHER ACKNOWLEDGE THAT THIS SHELL SCRIPT AND SERVICES ARE NOT
#    INTENDED OR SUITABLE FOR USE IN SITUATIONS OR ENVIRONMENTS WHERE THE FAILURE
#    OR TIME DELAYS OF, OR ERRORS OR INACCURACIES IN, THE CONTENT, DATA OR
#    INFORMATION PROVIDED BY THIS SHELL SCRIPT OR SERVICES COULD LEAD TO
#    DEATH, PERSONAL INJURY, OR SEVERE PHYSICAL OR ENVIRONMENTAL DAMAGE,
#    INCLUDING WITHOUT LIMITATION THE OPERATION OF NUCLEAR FACILITIES, AIRCRAFT
#    NAVIGATION OR COMMUNICATION SYSTEMS, AIR TRAFFIC CONTROL, LIFE SUPPORT OR
#    WEAPONS SYSTEMS.
#
# E. NO ORAL OR WRITTEN INFORMATION OR ADVICE GIVEN BY THE AUTHOR OF THIS SHELL SCRIPT
#    SHALL CREATE A WARRANTY. SHOULD THIS SHELL SCRIPT OR SERVICES PROVE DEFECTIVE,
#    YOU ASSUME THE ENTIRE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.
#
#    Limitation of Liability.
# F. TO THE EXTENT NOT PROHIBITED BY APPLICABLE LAW, IN NO EVENT SHALL THE
#    AUTHOR OF THIS SHELL SCRIPT BE LIABLE FOR PERSONAL INJURY, OR ANY
#    INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES WHATSOEVER,
#    INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, CORRUPTION OR
#    LOSS OF DATA, FAILURE TO TRANSMIT OR RECEIVE ANY DATA OR INFORMATION,
#    BUSINESS INTERRUPTION OR ANY OTHER COMMERCIAL DAMAGES OR LOSSES, ARISING
#    OUT OF OR RELATED TO YOUR USE OR INABILITY TO USE THIS SHELL SCRIPT OR
#    SERVICES OR ANY THIRD PARTY SOFTWARE OR APPLICATIONS IN CONJUNCTION WITH
#    THIS SHELL SCRIPT OR SERVICES, HOWEVER CAUSED, REGARDLESS OF THE THEORY OF
#    LIABILITY (CONTRACT, TORT OR OTHERWISE) AND EVEN IF THE AUTHOR OF THIS
#    SHELL SCRIPT HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. SOME
#    JURISDICTIONS DO NOT ALLOW THE EXCLUSION OR LIMITATION OF LIABILITY FOR
#    PERSONAL INJURY, OR OF INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THIS
#    LIMITATION MAY NOT APPLY TO YOU. In no event shall pak tool's total
#    liability to you for all damages (other than as may
#    be required by applicable law in cases involving personal injury) exceed
#    the amount of five dollars ($5.00). The foregoing limitations will apply
#    even if the above stated remedy fails of its essential purpose.
#
################################################################################
OLD_PATH="${PWD}"
# todo: signal here

AUTHOR="Mr. Walls"

builtin cd "${1}/.." ;
PROJECT_DIR=$(builtin pwd) ;
wait ;
builtin cd "${OLD_PWD}" ;
wait ;

echo "Manifest-Version: 1.0" ;
echo "Created-By: ${AUTHOR:-${LOGNAME}}" ;
echo "Signature-Version: 1.0" ;
#echo "Sealed: false"
echo "" ;

for FILE_TUPLE in $(find "${PROJECT_DIR}" -type f -iname "*.class" ) ;
do
    FILE_PATH="${FILE_TUPLE:${#PROJECT_DIR}}"
    # should do math in one line above but here is the hack to lose the trailing slash
    FILE_PATH="${FILE_PATH:1}"
	MD5DIGEST="00000000000000000000000000000000"
    if [[ `uname -s` == "Darwin" ]] ; then
	MD5DIGEST=$(md5 -q "${FILE_TUPLE}")
    else
	MD5DIGEST=$(openssl md5 "${FILE_TUPLE}" | \grep -oE -m 1 "[[:space:]]+[0123456789abcdef]{32}" | \grep -oE -m 1 "[0123456789abcdef]{32}")
	fi
    wait ;
    SHADIGEST=$(openssl sha1 "${FILE_PATH}" | \grep -oE -m 1 "[[:space:]]+[0123456789abcdef]{40}" | \grep -oE -m 1 "[0123456789abcdef]{40}")
    
    if [[ $(\uname -s) == "Darwin" ]] ; then
        TEMP_PATH=$(basename $(printf ${FILE_PATH} | tr '/' '.') ".class")
    elif [[ $(\uname -s) == "Linux" ]] ; then
        TEMP_PATH=$(basename $(printf ${FILE_PATH} | tr '/' '.') ".class")
    else
        exit 3;
    fi

echo "Name: ${FILE_PATH}"
#echo "Specification-Title: \"${TEMP_PATH}\"" ;
#echo "Specification-Vendor: unknown" ;
#echo "Specification-Version: 20130925.01" ;
echo "Implementation-Title: \"${TEMP_PATH}\""
echo "Implementation-Version:" $(/bin/date "+%C%y%M%d.%H" ) ;
#echo "Implementation-Vendor:\"${AUTHOR:-${LOGNAME}}\"" ;
echo "MD5-Digest: ${MD5DIGEST}"
echo "SHA-Digest: ${SHADIGEST}"
echo "Sealed: false"

echo "" ;

done



for FILE_EXTRA in "README" "LICENCE" ;
do
if [[ ( -r "${FILE_EXTRA}" ) ]] ; then

    FILE_PATH="${PROJECT_DIR}/${FILE_EXTRA}"

	MD5DIGEST="00000000000000000000000000000000"
    if [[ `uname -s` == "Darwin" ]] ; then
	MD5DIGEST=$(md5 -q "${FILE_EXTRA}")
    else
	MD5DIGEST=$(openssl md5 "${FILE_EXTRA}" | \grep -oE -m 1 "[[:space:]]+[0123456789abcdef]{32}" | \grep -oE -m 1 "[0123456789abcdef]{32}")
	fi
    wait ;
    SHADIGEST=$(openssl sha1 "${FILE_EXTRA}" | \grep -oE -m 1 "[[:space:]]+[0123456789abcdef]{40}" | \grep -oE -m 1 "[0123456789abcdef]{40}")
    

echo "Name: ${FILE_EXTRA}"
echo "Content-Type: text/plain"
echo "MD5-Digest: ${MD5DIGEST}"
echo "SHA-Digest: ${SHADIGEST}"
echo "Sealed: false"

echo "" ;

fi

done

exit 0;
