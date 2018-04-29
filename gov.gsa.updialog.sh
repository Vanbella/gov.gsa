#!/bin/sh

#  gov.gsa.updialog.sh
#  gov.gsa
#
#  Created by John Graphia on 4/29/18.
#  
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
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$description$updcount $d2" -button1 "Install" -button2 "Defer" -timeout 10 -countdown -alignCountdown left`
if [ $result == 0 ]; then
echo "I will Install Updates"
# l not i below to avoid installing updates and wrecking my VM. Think i not l below.
# softwareupdate -l -a
# We should probably think about destroying gov.gsa.sus.plist at this time
# That way machine reboots and upon next andy run gets a new list of updates. This would also reset the defer counter
elif [ $result == 2 ]; then
echo "I will defer installation"
dfrcnt=`$bddy -c "print :DeferCount" $tgt`
inc=$(($dfrcnt+1))
$bddy -c "set :DeferCount $inc " $tgt
fi
