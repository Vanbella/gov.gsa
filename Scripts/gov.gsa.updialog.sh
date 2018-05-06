#!/bin/bash
helper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
bddy=/usr/libexec/PlistBuddy
tgt=/Library/Preferences/gov.gsa.sus.plist
icon="/usr/local/GSAfiles/GSA-logo_blue.icns"
#
heading="Required Software Updates Count"
#
description="There are "
# updcount=`sofwtwareupdate -l|sed -e '/*/d' -e '1,4 d'|wc -l`|sed 's/^[ \t]*//'
# test code
updcount=`/usr/bin/defaults read $tgt UpdateCount `
#
d2="Security updates for your machine. If you do nothing this window will timeout in 15 minutes and updates will be installed."
d3="You can defer for"
d4=`/usr/bin/defaults read $tgt DeferDays `
d5="more days. Updates will be force installed on the final day and your machine will be rebooted. Please use Self-Service to perform updates and restart at your convenience."
#
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$description$updcount $d2 $d3 $d4 $d5" -button1 "Install" -button2 "Defer" -timeout 900 -countdown -alignCountdown left`
if [ $result == 0 ]; then
echo "I will Install Updates"
# sleep 900
#softwareupdate -i -a
#
# if grep "restart" then reboot with 15 minute timer and dialog no defer of reboot
#
else [ $result == 2 ];
# echo "User defered installation" to GSA log
# Increment Defer Counter
dfrcnt=`$bddy -c "print :DeferCount" $tgt`
inc=$(($dfrcnt+1))
$bddy -c "set :DeferCount $inc " $tgt
#
fi
#
# Decrement Defer Day counter
dfrday=`$bddy -c "print :DeferDays" $tgt`
if [ $dfrday == 0 ]; then
#  nudge every 3 days, X number of update are avail,
final="You can no longer defer. Updates will be installed and your system rebooted in 15 minutes"
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$final" -button1 "Install" -timeout 900 -countdown -alignCountdown left`
else
dec=$(($dfrday-1))
$bddy -c "set :DeferDays $dec " $tgt
#
fi
#
#if [$dfrday == 0]; then
##  nudge every 3 days, X number of update are avail,
#final="You can no longer defer. Updates will be installed and your system rebooted in 15 minutes"
#result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$final" -button1 "Install" -timeout 900 -countdown -alignCountdown left`
#else
#exit 0
##
#fi
#
