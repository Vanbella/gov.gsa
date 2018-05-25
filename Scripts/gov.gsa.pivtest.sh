#!/bin/sh
#  gov.gsa.pivtest.sh
#  gov.gsa
#
#  Created by John Graphia on 5/24/18.
#  
#################################################################
helper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
bddy=/usr/libexec/PlistBuddy
tgt=/Library/Preferences/gov.gsa.piv.plist
icon="/usr/local/GSAfiles/GSA-logo_blue.icns"
#################################################################
heading="PIV Card Test"
d1="We will now test your PIV card. Please insert it into your reader and then click the Test button"
d2="Your card has the required Keys and Certificates for PIV login"
d3="Your card does not have the required Keys and Certificates for PIV login"
#################################################################
# Setup plist
$bddy -c "add Keys array " $tgt &> /dev/null
$bddy -c "add State string " $tgt &> /dev/null
#
# user Dialog
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$d1" -button1 "Test"`
# Test PIV
#
for lst in $(security export-smartcard|grep labl|sed -e 's/labl : "//' -e 's/"//' -e 's/[[:space:]]//'|sort -u|tr -d ' ')
do
$bddy -c "add Keys:0 string "$lst"" $tgt &> /dev/null
#
done
#
# if Keys contains KeyForKeyManagement and KeyForDigitalSignature then Valid
stt=`$bddy -c "print :Keys" $tgt`
if [[ "$stt" == *"KeyForKeyManagement"* && "$stt" == *"KeyForDigitalSignature"* ]]; then
"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$d2" -button1 "Ok"
$bddy -c "set State Valid " $tgt &> /dev/null
else
# $bddy -c "set State: Valid " $tgt &> /dev/null
"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$d3" -button1 "Ok"
$bddy -c "set State NotValid " $tgt &> /dev/null
fi
