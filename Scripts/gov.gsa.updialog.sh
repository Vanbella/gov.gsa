#!/bin/bash
#################################################################
helper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
bddy=/usr/libexec/PlistBuddy
tgt=/Library/Preferences/gov.gsa.sus.plist
icon="/usr/local/GSAfiles/GSA-logo_blue.icns"
#################################################################
# Decrement Defer Day counter
dfrday=`$bddy -c "print :DeferDays" $tgt`
if [ $dfrday -eq 0 ]; then
#
#  If counter is 0 force patch
final="The Software Update deferal period has expired. Updates will be installed and your system rebooted in 15 minutes"
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$final" -button1 "Install" -timeout 900 -countdown -alignCountdown left`
softwareupdate -i -a
$bddy -c "set :DeferCount 0" $tgt
$bddy -c "set :DeferDays 8" $tgt
shutdown -r +15
else
#
#################################################################
#
heading="Required Software Updates Count"
###
description="There are "
updcount=`/usr/bin/defaults read $tgt UpdateCount `
###
d2="Security updates for your machine. If you do nothing this window will timeout in 15 minutes and updates will be installed."
d3="You can defer for"
d4=`/usr/bin/defaults read $tgt DeferDays `
d5="more days. Updates will be force installed on the final day and your machine will be rebooted. Please use Self-Service to perform updates and restart at your convenience."
###
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$description$updcount $d2 $d3 $d4 $d5" -button1 "Install" -button2 "Defer" -timeout 900 -countdown -alignCountdown left`
if [ $result -eq 0 ]; then
echo "I will Install Updates"
softwareupdate -i -a
$bddy -c "set :DeferCount 0" $tgt
$bddy -c "set :DeferDays 8" $tgt
shutdown -r +15
##
else
## echo "User defered installation" to GSA log
## Increment Defer Counter
dfrcnt=`$bddy -c "print :DeferCount" $tgt`
inc=$(($dfrcnt+1))
$bddy -c "set :DeferCount $inc " $tgt
dec=$(($dfrday-1))
$bddy -c "set :DeferDays $dec " $tgt
echo bddy
fi
fi
