#!/bin/bash
#################################################################
helper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
bddy=/usr/libexec/PlistBuddy
tgt=/Library/Preferences/com.apple.SoftwareUpdate.plist
sus=/Library/Preferences/gov.gsa.sus.plist
icon="/usr/local/GSAfiles/GSA-logo_blue.icns"
#################################################################
# create sus
#
#################################################################
#################################################################
#################################################################
#################################################################
#################################################################
#
lrua=`$bddy -c "print :LastRecommendedUpdatesAvailable" $tgt`
lua=`$bddy -c "print :LastUpdatesAvailable" $tgt`
if [[ $lrua -lt 1 ]]; then
exit 0
else
#################################################################
# Decrement Defer Day counter
dfrday=`$bddy -c "print :DeferDays" $sus`
if [[ $dfrday -eq 0 ]] ; then
#
#################################################################
#  If counter is 0 force patch
heading="Apple Security Update Deferal Expired"
final="The Software Update deferal period has expired. Apple Security Updates will be installed and your system rebooted in 15 minutes. You may click Install to perform the updates immediately."
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$final" -button1 "Install" -timeout 900 -countdown -alignCountdown left`
#################################################################
heading="Apple Security Updates are Being installed"
patch="Please do not Shutdown, Restart or Sleep your machine. Please save your work and quit all applications."
`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$patch" -timeout 30 -countdown -alignCountdown left `
softwareupdate -i -a
$bddy -c "set :DeferCount 0" $sus
$bddy -c "set :DeferDays 8" $sus
#################################################################
shutdown -r +15
heading="Updates Applied, Reboot in 15 minutes"
reboot="Apple Security Updates have been installed. Your machine will automatically reboot in 15 minutes or you may click Reboot Now. Please save your work and quit all applications."
`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$reboot" -timeout 900 -countdown -alignCountdown left`
else
#
#################################################################
#
heading="Apple Security Software Updates Available"
###
description="There are "
updcount=`/usr/bin/defaults read $tgt LastRecommendedUpdatesAvailable `
###
d2="Apple Security updates for your machine. If you do nothing this window will timeout in 8 hours and will decrement 1 day of deferment."
d3="You can defer for"
d4=`/usr/bin/defaults read $sus DeferDays `
d5="more days. Updates will be force installed on the final day and your machine will be rebooted. Please use Self-Service to perform updates and restart at your convenience."
###
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$description$updcount $d2 $d3 $d4 $d5" -button1 "Defer" -button2 "Install" -timeout 28800 -countdown -alignCountdown left`
####################
if [ $result -eq 0 ]; then
# User clicked defer 2
### Increment Defer Counter
dfrcnt=`$bddy -c "print :DeferCount" $sus`
inc=$(($dfrcnt+1))
$bddy -c "set :DeferCount $inc " $sus
dec=$(($dfrday-1))
$bddy -c "set :DeferDays $dec " $sus
####################
elif [ $result -eq 2 ]; then
# User clicked install 0
heading="Apple Security Updates are being installed"
patch="Please do not Shutdown, Restart or Sleep your machine. Please save your work and quit all applications."
`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$patch" -timeout 30 -countdown -alignCountdown left`
softwareupdate -i -a
$bddy -c "set :DeferCount 0" $sus
$bddy -c "set :DeferDays 8" $sus
####################
shutdown -r +15
heading="Updates Applied, Reboot in 15 minutes"
reboot="Apple Security Updates have been installed. Your machine will automatically reboot in 15 minutes. Please save your work and quit all applications in preparation for a full reboot."
`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$reboot" -timeout 900 -countdown -alignCountdown left`
####################
else
dfrcnt=`$bddy -c "print :DeferCount" $tgt`
inc=$(($dfrcnt+1))
$bddy -c "set :DeferCount $inc " $tgt
dec=$(($dfrday-1))
$bddy -c "set :DeferDays $dec " $tgt
echo Timeout
fi
fi
fi

