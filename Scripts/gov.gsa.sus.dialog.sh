#!/bin/sh

#  gov.gsa.sus.dialog.sh
#  gov.gsa
#
#  Created by John Graphia on 7/12/18.
#  
#################################################################
helper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
bddy=/usr/libexec/PlistBuddy
tgt=/Library/Preferences/com.apple.SoftwareUpdate.plist
sus=/Library/Preferences/gov.gsa.sus.plist
icon="/usr/local/GSAfiles/GSA-logo_blue.icns"
lrua=`$bddy -c "print :LastRecommendedUpdatesAvailable" $tgt`
lua=`$bddy -c "print :LastUpdatesAvailable" $tgt`
#################################################################

#################################################################
show_deferexpired () {
heading="Apple Security Update Deferal Expired"
final="The Software Update deferal period has expired. Apple Security Updates will be installed and your system rebooted in 15 minutes. You may click Install to perform the updates immediately."
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$final" -button1 "Install" -timeout 900 -countdown -alignCountdown left`
if [ $result -eq 0 ]; then
echo DeferTimedOut >> /var/log/GSAlog
#echo $result >> /var/log/GSAlog
else
echo $result >> /var/log/GSAlog
echo DeferExpired >> /var/log/GSAlog
fi
}
#################################################################

#################################################################
show_userinstall () {
heading="Apple Security Software Updates Available"
description="There are "
updcount=`/usr/bin/defaults read $tgt LastRecommendedUpdatesAvailable `
d2="Apple Security updates for your machine. If you do nothing this window will timeout in 8 hours and will decrement 1 day of deferment."
d3="You can defer for"
d4=`/usr/bin/defaults read $sus DeferDays `
d5="more days. Updates will be force installed on the final day and your machine will be rebooted. Please use Self-Service to perform updates and restart at your convenience."
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$description$updcount $d2 $d3 $d4 $d5" -button1 "Defer" -button2 "Install" -timeout 28800 -countdown -alignCountdown left`
if [ $result -eq 0 ]; then
# User clicked Defer button
### Increment Defer Counter
dfrcnt=`$bddy -c "print :DeferCount" $sus`
inc=$(($dfrcnt+1))
$bddy -c "set :DeferCount $inc " $sus
dec=$(($dfrday-1))
$bddy -c "set :DeferDays $dec " $sus
else
install_updates
reboot_timer
fi
}
#################################################################
# Install Updates
install_updates () {
heading="Apple Security Updates are being installed"
patch="Install will begin in 30 seconds. Please do not Shutdown, Restart or Sleep your machine. Please save your work and quit all applications."
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$patch" -timeout 30 -countdown -alignCountdown left `
if [ $result -eq 243 ]; then
#caffeinate -d -i -m
softwareupdate -i -a
echo InstallUpdatesTimeout >> /var/log/GSAlog
$bddy -c "set :DeferCount 0" $sus
$bddy -c "set :DeferDays 8" $sus
else
#caffeinate -d -i -m -u
softwareupdate -i -a
echo InstallUpdatesButton >> /var/log/GSAlog
fi
}
#################################################################

#################################################################
reboot_timer (){
shutdown -r +16
echo Reboot >> /var/log/GSAlog
heading="Updates Applied, Reboot in 15 minutes"
reboot="Apple Security Updates have been installed. Your machine will automatically reboot in 15 minutes or you may reboot via the Apple Menu. Please save your work and quit all applications in preparation for a full reboot."
result=`"$helper" -windowType hud -lockHUD -title "$heading" -alignHeading center -icon "$icon" -iconSize 96 -description "$reboot" -timeout 900 -countdown -alignCountdown left`
if [ $result -eq 0 ]; then
echo RebootTimedOut >> /var/log/GSAlog
#echo $result >> /var/log/GSAlog
else
echo $result >> /var/log/GSAlog
echo RebootExpired >> /var/log/GSAlog
fi
}

#################################################################

#################################################################
# DeferCount and DeferDays code
modify_counters () {
dfrcnt=`$bddy -c "print :DeferCount" $tgt`
inc=$(($dfrcnt+1))
$bddy -c "set :DeferCount $inc " $tgt
dec=$(($dfrday-1))
$bddy -c "set :DeferDays $dec " $tgt
echo Timeout
}
#################################################################
# Start # If there are no updates listed in :LastRecommendedUpdatesAvailable
#################################################################
if [[ $lrua -lt 1 ]]; then
echo NoUpdatesNeeded >> /var/log/GSAlog
exit 0
else
echo UpdatesNeeded >> /var/log/GSAlog
fi
#################################################################
#
#################################################################
#  If Defer Day counter is 0 force patch
dfrday=`$bddy -c "print :DeferDays" $sus`
if [[ $dfrday -eq 0 ]] ; then
show_deferexpired
install_updates
reboot_timer
else
echo DeferDaysNotExpired >> /var/log/GSAlog
show_userinstall
fi
exit 0



