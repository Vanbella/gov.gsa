#!/bin/bash
helper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
bddy=/usr/libexec/PlistBuddy
tgt=/Library/Preferences/gov.gsa.sus.plist
icon="/usr/local/GSAfiles/GSA-logo_blue.icns"
#
heading="Required Software Updates Count"
#
description="There are"
# updcount=`sofwtwareupdate -l|sed -e '/*/d' -e '1,4 d'|wc -l`|sed 's/^[ \t]*//'
# test code
updcount=`/usr/bin/defaults read $tgt UpdateCount `
#
d2="Security updates for your machine. If you do nothing the window will timeout in 10 seconds and install updates."
#
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$description$updcount $d2" -button1 "Install" -button2 "Defer" -timeout 900 -countdown -alignCountdown left`
if [ $result == 0 ]; then
echo "I will Install Updates"
# l not i below to avoid installing updates and wrecking my VM. Think i not l below.
# softwareupdate -i -a
# We should probably think about destroying gov.gsa.sus.plist at this time
# That way machine reboots and upon next andy run gets a new list of updates. This would also reset the defer counter
## workflow
# softwareupdate -i -a

# if grep "restart" then reboot with 15 minute timer and dialog no defer of reboot
#
else [ $result == 2 ]; then
echo "I will defer installation"
dfrcnt=`$bddy -c "print :DeferCount" $tgt`
inc=$(($dfrcnt+1))
$bddy -c "set :DeferCount $inc " $tgt
# nudge every 3 days, X number of update are avail, You have can defer for X number of days. Updates will be force installed in X days
# Go to Self-Service to perform updates and restart at your convenience.
fi

